import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../models/assistant.dart';
import '../models/language_config.dart';
import '../services/raise_api_service.dart';

class AIService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  
  // Clé API chargée depuis les variables d'environnement
  String get _apiKey => EnvConfig.geminiApiKey;
  
  // Configuration linguistique
  LanguageConfig _languageConfig = LanguageConfig.french();
  
  final RaiseApiService _raiseService = RaiseApiService();
  
  // Gestion des requêtes HTTP en cours
  final List<http.Client> _activeClients = [];
  bool _isCancelled = false;
  
  void updateLanguageConfig(LanguageConfig config) {
    _languageConfig = config;
  }
  
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
    final summarizePrompt = _languageConfig.aiSummarizePrompt + text;
    
    return _generateGeminiResponse(summarizePrompt, null);
  }

  String _getSystemResponseForLanguage() {
    switch (_languageConfig.speechToTextLocale.split('-')[0]) {
      case 'en':
        return 'Understood! I am your voice assistant. I will respond naturally and conversationally in English. How can I help you?';
      case 'ja':
        return '分かりました！私はあなたの音声アシスタントです。日本語で自然に会話形式で回答します。どのようにお手伝いできますか？';
      case 'fr':
      default:
        return 'Compris ! Je suis votre assistant vocal. Je répondrai de manière naturelle et conversationnelle en français. Comment puis-je vous aider ?';
    }
  }

  Future<String> _generateGeminiResponse(String prompt, [List<String>? conversationHistory]) async {
    // Construire l'historique de conversation pour Gemini
    List<Map<String, dynamic>> contents = [];
    
    // Ajouter l'instruction système localisée
    contents.add({
      'role': 'user',
      'parts': [
        {'text': _languageConfig.aiSystemPrompt}
      ]
    });
    
    contents.add({
      'role': 'model',
      'parts': [
        {'text': _getSystemResponseForLanguage()}
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

    // Créer un client HTTP pour pouvoir l'annuler
    final client = http.Client();
    _activeClients.add(client);
    
    try {
      // Vérifier si annulé avant la requête
      if (_isCancelled) {
        throw Exception('Requête annulée');
      }
      
      final response = await client.post(
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
      
      // Vérifier si annulé après la requête
      if (_isCancelled) {
        throw Exception('Requête annulée');
      }

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
      if (e.toString().contains('annulée')) {
        return "Requête annulée par l'utilisateur.";
      }
      return "Une erreur s'est produite lors de la génération de la réponse.";
    } finally {
      // Nettoyer le client de la liste
      _activeClients.remove(client);
      client.close();
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
  
  /// Annuler toutes les requêtes HTTP en cours
  void cancelAllRequests() {
    print('🚫 Annulation de toutes les requêtes HTTP en cours...');
    _isCancelled = true;
    
    // Fermer tous les clients HTTP actifs
    for (final client in _activeClients) {
      try {
        client.close();
      } catch (e) {
        print('Erreur lors de la fermeture du client: $e');
      }
    }
    _activeClients.clear();
    
    // Annuler aussi les requêtes Raise
    _raiseService.cancelAllRequests();
  }
  
  /// Reset du service - remettre dans l'état initial
  void reset() {
    print('🔄 Reset du service AI...');
    cancelAllRequests();
    _isCancelled = false;
    // Pas besoin de reset d'autres états car ils sont recréés à chaque requête
  }
}