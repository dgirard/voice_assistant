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
  
  bool get isListening => _speechToText.isListening;
  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;
  String get currentLocale => _currentLocale;
  
  Function(String)? _onErrorCallback;
  
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
    _currentLocale = localeId;
    
    // Reconfigurer TTS avec la nouvelle langue
    await _flutterTts.setLanguage(_currentLocale);
    
    // Arrêter l'écoute actuelle si en cours
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
    
    // Réinitialiser le service de reconnaissance vocale avec la nouvelle langue
    if (_speechEnabled) {
      await _speechToText.stop();
      // Petit délai pour s'assurer que le service est complètement arrêté
      await Future.delayed(const Duration(milliseconds: 100));
      
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
    }
  }

  List<String> getSupportedLocales() {
    return ['fr-FR', 'en-US', 'ja-JP'];
  }

  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
  }
}