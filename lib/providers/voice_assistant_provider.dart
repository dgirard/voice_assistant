import 'package:flutter/foundation.dart';
import '../services/speech_service.dart';
import '../services/ai_service.dart';
import 'dart:async';

enum AssistantState {
  idle,
  listening,
  thinking,
  speaking,
  error
}

class VoiceAssistantProvider with ChangeNotifier {
  final SpeechService _speechService = SpeechService();
  final AIService _aiService = AIService();
  
  AssistantState _state = AssistantState.idle;
  String _currentText = '';
  String _lastResponse = '';
  List<String> _conversationHistory = [];
  bool _isInitialized = false;
  bool _isRecording = false;
  int _retryCount = 0;
  double _currentSoundLevel = 0.0;
  static const int _maxRetries = 3;
  static const int _maxHistoryItems = 100;
  
  AssistantState get state => _state;
  String get currentText => _currentText;
  String get lastResponse => _lastResponse;
  List<String> get conversationHistory => _conversationHistory;
  bool get isInitialized => _isInitialized;
  bool get isListening => _speechService.isListening;
  bool get isRecording => _isRecording;
  double get currentSoundLevel => _currentSoundLevel;
  
  Future<void> initialize() async {
    try {
      _isInitialized = await _speechService.initialize();
      if (_isInitialized) {
        _setState(AssistantState.idle);
      } else {
        _setState(AssistantState.error);
      }
    } catch (e) {
      _setState(AssistantState.error);
      print('Erreur d\'initialisation: $e');
    }
    notifyListeners();
  }
  
  /// Démarrer l'enregistrement vocal (Push-to-Talk)
  Future<void> startRecording() async {
    if (!_isInitialized || _state != AssistantState.idle) return;
    
    _isRecording = true;
    _setState(AssistantState.listening);
    _currentText = '';
    _retryCount = 0; // Reset du compteur
    
    await _speechService.startListening(
      onResult: (text) {
        _currentText = text;
        notifyListeners();
      },
      onError: (error) {
        print('Erreur speech: $error');
        // En mode push-to-talk, on ne redémarre pas automatiquement
        _stopRecordingWithError();
      },
      onSoundLevelChange: (level) {
        // Mettre à jour le niveau sonore pour l'animation
        _currentSoundLevel = level;
        notifyListeners();
      }
    );
    
    notifyListeners();
  }
  
  /// Arrêter l'enregistrement et traiter le message
  Future<void> stopRecording() async {
    if (!_isRecording || _state != AssistantState.listening) return;
    
    _isRecording = false;
    await _speechService.stopListening();
    
    // Réinitialiser le niveau sonore
    _currentSoundLevel = 0.0;
    
    // Attendre que le speech-to-text finalise la transcription
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentText.isNotEmpty) {
      await _processUserInput(_currentText);
    } else {
      _setState(AssistantState.idle);
    }
    
    notifyListeners();
  }
  
  /// Arrêter l'enregistrement en cas d'erreur
  void _stopRecordingWithError() {
    _isRecording = false;
    _currentSoundLevel = 0.0;
    _setState(AssistantState.error);
    notifyListeners();
    
    // Retour automatique à idle après 2 secondes
    Timer(const Duration(seconds: 2), () {
      if (_state == AssistantState.error) {
        _setState(AssistantState.idle);
        notifyListeners();
      }
    });
  }
  
  /// Traiter l'input utilisateur et obtenir une réponse IA
  Future<void> _processUserInput(String userInput) async {
    _setState(AssistantState.thinking);
    
    try {
      // Ajouter à l'historique avec limitation
      _conversationHistory.add('Vous: $userInput');
      _conversationHistory.add('Assistant: [En cours...]');
      
      // Limiter la taille de l'historique
      if (_conversationHistory.length > _maxHistoryItems) {
        _conversationHistory.removeRange(0, _conversationHistory.length - _maxHistoryItems);
      }
      
      // Formater le prompt
      String prompt = _aiService.formatPromptForAssistant(userInput);
      
      // Obtenir la réponse de l'IA avec l'historique de conversation
      String response = await _aiService.generateResponse(prompt, _conversationHistory);
      _lastResponse = response;
      
      // Remplacer le message temporaire
      _conversationHistory[_conversationHistory.length - 1] = 'Assistant: $response';
      
      // Parler la réponse
      _setState(AssistantState.speaking);
      await _speechService.speak(response);
      
      // Retour à l'état idle
      _setState(AssistantState.idle);
      
    } catch (e) {
      _setState(AssistantState.error);
      print('Erreur lors du traitement: $e');
      
      // Retour automatique à idle après erreur
      Timer(const Duration(seconds: 3), () {
        if (_state == AssistantState.error) {
          _setState(AssistantState.idle);
          notifyListeners();
        }
      });
    }
    
    notifyListeners();
  }
  
  /// Arrêter la synthèse vocale
  Future<void> stopSpeaking() async {
    await _speechService.stop();
    _setState(AssistantState.idle);
    notifyListeners();
  }
  
  /// Vider l'historique de conversation
  void clearHistory() {
    _conversationHistory.clear();
    _currentText = '';
    _lastResponse = '';
    notifyListeners();
  }
  
  void _setState(AssistantState newState) {
    _state = newState;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }
}