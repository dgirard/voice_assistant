import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get geminiApiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY not found. Please:\n'
        '1. Create a .env file in the root directory\n'
        '2. Add: GEMINI_API_KEY=your_actual_key\n'
        '3. Get a key from: https://makersuite.google.com/app/apikey'
      );
    }
    return key;
  }
  
  static String get appName => dotenv.env['APP_NAME'] ?? 'Voice Assistant';
  static bool get debugMode => dotenv.env['DEBUG_MODE'] == 'true';
  
  /// Vérifier que toutes les variables d'environnement nécessaires sont présentes
  static void validateEnvironment() {
    try {
      geminiApiKey; // Cette ligne lèvera une exception si la clé n'existe pas
      print('✅ Configuration environment validée');
    } catch (e) {
      print('❌ Erreur configuration: $e');
      rethrow;
    }
  }
}