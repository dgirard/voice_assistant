import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  // Vous devez remplacer cette clé par votre vraie clé API Gemini
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';
  
  Future<String> generateResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
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
  
  String formatPromptForAssistant(String userInput) {
    return """Tu es un assistant vocal intelligent et serviable. 
Réponds de manière conversationnelle et naturelle en français. 
Garde tes réponses concises mais informatives.

Question de l'utilisateur: $userInput

Réponse:""";
  }
}