import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _speechEnabled = false;
  bool _speechAvailable = false;
  String _lastWords = '';
  String _currentLocale = 'fr-FR';
  bool _isUpdatingLanguage = false;
  
  bool get isListening => _speechToText.isListening;
  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;
  String get currentLocale => _currentLocale;
  
  Function(String)? _onErrorCallback;
  
  /// Définir la langue avant l'initialisation
  void setInitialLanguage(String localeId) {
    _currentLocale = localeId;
    print('Langue initiale définie: $_currentLocale');
  }
  
  Future<bool> initialize() async {
    var permissionStatus = await Permission.microphone.request();
    
    if (permissionStatus != PermissionStatus.granted) {
      return false;
    }
    
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) {
        print('Speech error: $error');
        // Notifier l'erreur pour redémarrage automatique
        if (_onErrorCallback != null) {
          _onErrorCallback!(error.errorMsg);
        }
      },
    );
    
    _speechAvailable = _speechEnabled;
    
    await _flutterTts.setLanguage(_currentLocale);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    
    return _speechEnabled;
  }
  
  Future<void> startListening({
    required Function(String) onResult, 
    Function(String)? onError,
    Function(double)? onSoundLevelChange
  }) async {
    if (!_speechEnabled) return;
    
    _onErrorCallback = onError;
    
    await _speechToText.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        onResult(_lastWords);
      },
      listenFor: const Duration(seconds: 30), // Durée raisonnable
      pauseFor: const Duration(seconds: 3), // Pause optimisée
      partialResults: true,
      localeId: _currentLocale,
      listenMode: ListenMode.dictation,
      onSoundLevelChange: (level) {
        // Transmettre le niveau sonore pour l'animation
        if (onSoundLevelChange != null) {
          onSoundLevelChange(level);
        }
      },
    );
  }
  
  Future<void> stopListening() async {
    await _speechToText.stop();
  }
  
  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }
  
  Future<void> stop() async {
    await _flutterTts.stop();
  }
  
  Future<void> updateLanguage(String localeId) async {
    // Éviter les appels concurrents
    if (_isUpdatingLanguage) {
      print('Mise à jour de langue déjà en cours, ignorer...');
      return;
    }
    
    _isUpdatingLanguage = true;
    
    try {
      _currentLocale = localeId;
      
      // Reconfigurer TTS avec la nouvelle langue
      await _flutterTts.setLanguage(_currentLocale);
      
      // Arrêter l'écoute actuelle si en cours de façon sûre
      if (_speechToText.isListening) {
        try {
          await _speechToText.cancel();
        } catch (e) {
          print('Erreur lors de l\'arrêt de l\'écoute: $e');
        }
      }
      
      // Réinitialiser le service de reconnaissance vocale avec la nouvelle langue
      // Seulement si nécessaire (optimisation)
      if (_speechEnabled && localeId != _currentLocale) {
        try {
          await _speechToText.stop();
          // Petit délai pour s'assurer que le service est complètement arrêté
          await Future.delayed(const Duration(milliseconds: 200));
          
          // Réinitialiser avec la nouvelle configuration de langue
          _speechEnabled = await _speechToText.initialize(
            onStatus: (status) => print('Speech status: $status'),
            onError: (error) {
              print('Speech error: $error');
              if (_onErrorCallback != null) {
                _onErrorCallback!(error.errorMsg);
              }
            },
          );
          
          print('Speech service réinitialisé pour la langue: $_currentLocale');
        } catch (e) {
          print('Erreur lors de la réinitialisation du speech service: $e');
          // En cas d'erreur, essayer une réinitialisation complète
          _speechEnabled = false;
          await initialize();
        }
      }
    } finally {
      _isUpdatingLanguage = false;
    }
  }

  List<String> getSupportedLocales() {
    return ['fr-FR', 'en-US', 'ja-JP'];
  }

  void dispose() {
    try {
      if (_speechToText.isListening) {
        _speechToText.cancel();
      }
    } catch (e) {
      print('Erreur lors du dispose speech: $e');
    }
    
    try {
      _flutterTts.stop();
    } catch (e) {
      print('Erreur lors du dispose TTS: $e');
    }
  }
}