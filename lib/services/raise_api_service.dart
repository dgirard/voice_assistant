import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/assistant.dart';

class RaiseApiService {
  static const String baseUrl = 'https://raise.sfeir.com';
  late final String _apiKey;
  
  // Gestion des requêtes HTTP en cours
  final List<http.Client> _activeClients = [];

  RaiseApiService() {
    _apiKey = dotenv.env['RAISE_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('RAISE_API_KEY not found in environment variables');
    }
  }

  Map<String, String> get _headers => {
    'X-API-Key': _apiKey,
    'Content-Type': 'application/json',
  };

  Future<List<Assistant>> getVoiceAssistants() async {
    try {
      final url = Uri.parse('$baseUrl/v2/assistants/');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> assistantsJson = json.decode(response.body) as List<dynamic>;
        
        // Filtrer les assistants contenant "#Voice"
        final voiceAssistants = assistantsJson
            .where((assistant) {
              final name = assistant['name'] as String? ?? '';
              return name.contains('#Voice');
            })
            .map((assistant) => Assistant.fromRaiseJson(assistant))
            .toList();

        return voiceAssistants;
      } else {
        throw Exception('Failed to load assistants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching assistants: $e');
    }
  }

  Future<String> createThread(String assistantId, String threadName) async {
    try {
      final url = Uri.parse('$baseUrl/v2/threads');
      final body = json.encode({
        'name': threadName,
        'assistant_id': assistantId,
      });

      final response = await http.post(url, headers: _headers, body: body);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['id'] as String;
      } else {
        throw Exception('Failed to create thread: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating thread: $e');
    }
  }

  Future<String> interactWithAssistant(
    String assistantId,
    String threadId,
    String message,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/v2/interact/invocation');
      final body = json.encode({
        'assistant_id': assistantId,
        'message': message,
        'thread_id': threadId,
      });

      final response = await http.post(url, headers: _headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        final rawResponse = responseData['llm_output'] as String? ?? '';
        return _cleanResponse(rawResponse);
      } else {
        throw Exception('Failed to interact with assistant: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error interacting with assistant: $e');
    }
  }

  String _cleanResponse(String response) {
    // Nettoyer les caractères échappés et unicode
    String cleaned = response
        .replaceAll('""', '')
        .replaceAll('\\"', '')
        .replaceAll('\\u00e9', 'é')
        .replaceAll('\\u00e8', 'è')
        .replaceAll('\\u00ea', 'ê')
        .replaceAll('\\u00e0', 'à')
        .replaceAll('\\u00f4', 'ô')
        .replaceAll('\\u00e7', 'ç')
        .replaceAll('\\u00f9', 'ù')
        .replaceAll('\\u20ac', '€')
        .replaceAll('\\u00ef', 'ï')
        .replaceAll('\\u00eb', 'ë')
        .replaceAll('\\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return cleaned;
  }

  int _countWords(String text) {
    return text.trim().split(RegExp(r'\s+')).length;
  }

  bool shouldSummarize(String response) {
    return _countWords(response) > 100;
  }
  
  /// Annuler toutes les requêtes HTTP en cours
  void cancelAllRequests() {
    print('🚫 Annulation des requêtes Raise API...');
    
    // Fermer tous les clients HTTP actifs
    for (final client in _activeClients) {
      try {
        client.close();
      } catch (e) {
        print('Erreur lors de la fermeture du client Raise: $e');
      }
    }
    _activeClients.clear();
  }
}