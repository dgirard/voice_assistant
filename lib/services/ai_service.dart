import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../models/assistant.dart';
import '../services/raise_api_service.dart';

class AIService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  
  // Clé API chargée depuis les variables d'environnement
  String get _apiKey => EnvConfig.geminiApiKey;
  
  final RaiseApiService _raiseService = RaiseApiService();
  
  Future<String> generateResponse(
    String prompt, {
    List<String>? conversationHistory,
    Assistant? assistant,
    String? threadId,
  }) async {
    if (assistant != null && assistant.type == AssistantType.raise) {
      return _generateRaiseResponse(prompt, assistant, threadId);
    }
    return _generateGeminiResponse(prompt, conversationHistory);
  }

  Future<String> _generateRaiseResponse(
    String prompt,
    Assistant assistant,
    String? threadId,
  ) async {
    try {
      if (threadId == null) {
        throw Exception('Thread ID is required for Raise assistant');
      }

      final response = await _raiseService.interactWithAssistant(
        assistant.id,
        threadId,
        prompt,
      );

      // Vérifier si la réponse doit être résumée
      if (_raiseService.shouldSummarize(response)) {
        return await _summarizeWithGemini(response);
      }

      return response;
    } catch (e) {
      print('Erreur Raise: $e');
      return "Erreur lors de la communication avec l'assistant Raise.";
    }
  }

  Future<String> _summarizeWithGemini(String text) async {
    final summarizePrompt = 
        "Résume ce texte en exactement 100 mots maximum pour une réponse vocale, "
        "en gardant les informations les plus importantes comme les noms propres : $text";
    
    return _generateGeminiResponse(summarizePrompt, null);
  }

  Future<String> _generateGeminiResponse(String prompt, [List<String>? conversationHistory]) async {
    try {
      // Construire l'historique de conversation pour Gemini
      List<Map<String, dynamic>> contents = [];
      
      // Ajouter l'instruction système
      contents.add({
        'role': 'user',
        'parts': [
          {'text': 'Tu es un assistant vocal intelligent et serviable. Réponds de manière conversationnelle et naturelle en français. Garde tes réponses concises mais informatives.'}
        ]
      });
      
      contents.add({
        'role': 'model',
        'parts': [
          {'text': 'Compris ! Je suis votre assistant vocal. Je répondrai de manière naturelle et conversationnelle en français. Comment puis-je vous aider ?'}
        ]
      });
      
      // Ajouter l'historique de conversation si disponible
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        for (String message in conversationHistory) {
          if (message.startsWith('Vous: ')) {
            contents.add({
              'role': 'user',
              'parts': [
                {'text': message.substring(6)} // Retirer "Vous: "
              ]
            });
          } else if (message.startsWith('Assistant: ') && !message.contains('[En cours...]')) {
            contents.add({
              'role': 'model',
              'parts': [
                {'text': message.substring(11)} // Retirer "Assistant: "
              ]
            });
          }
        }
      }
      
      // Ajouter le message actuel
      contents.add({
        'role': 'user',
        'parts': [
          {'text': prompt}
        ]
      });

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          return "Désolé, je n'ai pas pu générer une réponse.";
        }
      } else {
        print('Erreur API: ${response.statusCode} - ${response.body}');
        return "Erreur lors de la communication avec l'IA.";
      }
    } catch (e) {
      print('Erreur: $e');
      return "Une erreur s'est produite lors de la génération de la réponse.";
    }
  }

  Future<List<Assistant>> getAvailableAssistants() async {
    try {
      final List<Assistant> assistants = [Assistant.gemini()];
      
      // Ajouter les assistants Raise
      final raiseAssistants = await _raiseService.getVoiceAssistants();
      assistants.addAll(raiseAssistants);
      
      return assistants;
    } catch (e) {
      print('Erreur lors du chargement des assistants Raise: $e');
      // En cas d'erreur, retourner seulement Gemini
      return [Assistant.gemini()];
    }
  }

  Future<String> createRaiseThread(Assistant assistant) async {
    if (assistant.type != AssistantType.raise) {
      throw Exception('Only Raise assistants can create threads');
    }
    
    final threadName = 'Voice Conversation ${DateTime.now().millisecondsSinceEpoch}';
    return await _raiseService.createThread(assistant.id, threadName);
  }
  
  String formatPromptForAssistant(String userInput) {
    // Cette méthode est maintenant simplifiée car le contexte est géré dans generateResponse
    return userInput;
  }
}