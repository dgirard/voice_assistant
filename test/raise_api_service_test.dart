import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:voice_assistant/services/raise_api_service.dart';
import 'package:voice_assistant/models/assistant.dart';

void main() {
  group('RaiseApiService Tests', () {
    setUpAll(() async {
      // Initialiser dotenv avec des valeurs de test
      dotenv.testLoad(mergeWith: {'RAISE_API_KEY': 'test_api_key'});
    });

    test('should handle API initialization', () {
      // Test simple de création du service
      expect(() => RaiseApiService(), returnsNormally);
    });

    test('should validate getVoiceAssistants method exists', () {
      final raiseApiService = RaiseApiService();
      
      // Vérifier que la méthode existe
      expect(raiseApiService.getVoiceAssistants, isA<Function>());
    });

    test('should handle network errors gracefully', () async {
      final raiseApiService = RaiseApiService();
      
      try {
        // Ce test va probablement échouer à cause de la fausse clé API
        await raiseApiService.getVoiceAssistants();
        
        // Si ça fonctionne, on vérifie le type de retour
        fail('Expected an exception due to invalid API key');
      } catch (e) {
        // Vérifier que l'erreur est bien gérée
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Error fetching assistants'));
        print('✅ Test passé - Erreur gérée correctement: ${e.toString().substring(0, 100)}...');
      }
    }, timeout: const Timeout(Duration(seconds: 10)));

  });
}