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
  
  bool get isListening => _speechToText.isListening;
  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;
  
  Future<bool> initialize() async {
    var permissionStatus = await Permission.microphone.request();
    
    if (permissionStatus != PermissionStatus.granted) {
      return false;
    }
    
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );
    
    _speechAvailable = _speechEnabled;
    
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    
    return _speechEnabled;
  }
  
  Future<void> startListening({required Function(String) onResult}) async {
    if (!_speechEnabled) return;
    
    await _speechToText.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        onResult(_lastWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: "fr-FR",
      listenMode: ListenMode.confirmation,
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
  
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
  }
}