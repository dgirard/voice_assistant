import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assistant.dart';

class AssistantPersistence {
  static const String _assistantKey = 'selected_assistant';

  static Future<void> saveSelectedAssistant(Assistant assistant) async {
    final prefs = await SharedPreferences.getInstance();
    final assistantJson = json.encode(assistant.toJson());
    await prefs.setString(_assistantKey, assistantJson);
  }

  static Future<Assistant?> getSelectedAssistant() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assistantJson = prefs.getString(_assistantKey);
      
      if (assistantJson != null) {
        final assistantMap = json.decode(assistantJson) as Map<String, dynamic>;
        return Assistant.fromJson(assistantMap);
      }
    } catch (e) {
      // En cas d'erreur, retourner null pour utiliser l'assistant par défaut
      print('Error loading saved assistant: $e');
    }
    
    return null;
  }

  static Future<void> clearSelectedAssistant() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_assistantKey);
  }
}