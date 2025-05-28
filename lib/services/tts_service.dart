import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'gemini_tts_test.dart';

enum TtsEngine {
  android,  // TTS Android standard
  gemini    // TTS Gemini AI
}

abstract class TtsService {
  Future<void> speak(String text);
  Future<void> stop();
  void dispose();
}

/// Option 1: TTS Android Standard (Recommandée)
class AndroidTtsService implements TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    
    // Configuration avancée pour Android
    await _flutterTts.awaitSpeakCompletion(true);
    
    // Essayer d'utiliser une voix de meilleure qualité si disponible
    try {
      final voices = await _flutterTts.getVoices;
      final frenchVoices = voices.where((voice) => 
        voice['locale'].toString().startsWith('fr')).toList();
      
      if (frenchVoices.isNotEmpty) {
        // Préférer les voix neurales ou de haute qualité
        final neuralVoice = frenchVoices.firstWhere(
          (voice) => voice['name'].toString().toLowerCase().contains('neural') ||
                    voice['name'].toString().toLowerCase().contains('premium') ||
                    voice['name'].toString().toLowerCase().contains('enhanced'),
          orElse: () => frenchVoices.first,
        );
        await _flutterTts.setVoice(neuralVoice);
        print('Voix sélectionnée: ${neuralVoice['name']}');
      }
    } catch (e) {
      print('Impossible de configurer une voix spécifique: $e');
    }

    _isInitialized = true;
  }

  @override
  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    await _flutterTts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  @override
  void dispose() {
    _flutterTts.stop();
  }

  // Méthodes supplémentaires pour Android TTS
  Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
  }

  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  Future<List<dynamic>> getVoices() async {
    return await _flutterTts.getVoices;
  }
}

/// Option 2: TTS Gemini AI (utilise le système de test avancé)
class GeminiTtsService implements TtsService {
  final String _apiKey;
  late GeminiTtsTest _geminiTest;

  GeminiTtsService({required String apiKey}) : _apiKey = apiKey {
    _geminiTest = GeminiTtsTest(apiKey: apiKey);
  }

  @override
  Future<void> speak(String text) async {
    try {
      print('🎙️ Utilisation du système Gemini TTS avancé...');
      
      // Utiliser le système de test avancé qui fonctionne
      final success = await _geminiTest.testGeminiTts(
        text: text,
        voiceName: 'Kore',
      );
      
      if (!success) {
        throw Exception('Échec génération audio Gemini');
      }
      
      print('✅ Gemini TTS avancé terminé avec succès');
      
    } catch (e) {
      print('❌ Erreur TTS Gemini: $e');
      
      // Fallback vers Android TTS avec message informatif
      final fallback = AndroidTtsService();
      await fallback.initialize();
      await fallback.speak('Gemini TTS a rencontré une erreur. Voici la voix Android standard.');
      
      // Ne pas faire de throw pour éviter les crashes
      print('ℹ️ Fallback vers Android TTS effectué');
    }
  }


  @override
  Future<void> stop() async {
    try {
      // Le système de test Gemini ne supporte pas encore l'arrêt
      // On pourrait ajouter cette fonctionnalité au plugin Android si nécessaire
      print('ℹ️ Arrêt demandé pour Gemini TTS');
    } catch (e) {
      print('Erreur arrêt audio: $e');
    }
  }

  @override
  void dispose() {
    stop();
  }
}

/// Factory pour créer le service TTS approprié
class TtsServiceFactory {
  static TtsService create(TtsEngine engine, {String? geminiApiKey}) {
    switch (engine) {
      case TtsEngine.android:
        return AndroidTtsService();
      case TtsEngine.gemini:
        if (geminiApiKey == null) {
          throw ArgumentError('Gemini API key requis pour TTS Gemini');
        }
        return GeminiTtsService(apiKey: geminiApiKey);
    }
  }
}