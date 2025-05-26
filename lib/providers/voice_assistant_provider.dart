import 'package:flutter/foundation.dart';
import '../services/speech_service.dart';
import '../services/ai_service.dart';
import 'dart:async';

enum AssistantState {
  paused,
  idle,
  listening,
  thinking,
  speaking,
  error
}

class VoiceAssistantProvider with ChangeNotifier {
  final SpeechService _speechService = SpeechService();
  final AIService _aiService = AIService();
  
  AssistantState _state = AssistantState.paused;
  String _currentText = '';
  String _lastResponse = '';
  List<String> _conversationHistory = [];
  bool _isInitialized = false;
  bool _continuousListening = false;
  Timer? _restartTimer;
  int _retryCount = 0;
  static const int _maxRetries = 5;
  static const int _maxHistoryItems = 100;
  
  AssistantState get state => _state;
  String get currentText => _currentText;
  String get lastResponse => _lastResponse;
  List<String> get conversationHistory => _conversationHistory;
  bool get isInitialized => _isInitialized;
  bool get isListening => _speechService.isListening;
  bool get continuousListening => _continuousListening;
  
  Future<void> initialize() async {
    try {
      _isInitialized = await _speechService.initialize();
      if (_isInitialized) {
        _setState(AssistantState.paused);
      } else {
        _setState(AssistantState.error);
      }
    } catch (e) {
      _setState(AssistantState.error);
      print('Erreur d\'initialisation: $e');
    }
    notifyListeners();
  }
  
  Future<void> togglePause() async {
    if (_state == AssistantState.paused) {
      // Démarrer l'écoute continue
      _continuousListening = true;
      _setState(AssistantState.idle);
      await _startContinuousListening();
    } else {
      // Mettre en pause
      _continuousListening = false;
      _restartTimer?.cancel();
      await stopListening();
      _setState(AssistantState.paused);
    }
    notifyListeners();
  }
  
  Future<void> _startContinuousListening() async {
    if (!_continuousListening || _state == AssistantState.paused) return;
    
    _setState(AssistantState.listening);
    _currentText = '';
    
    await _speechService.startListening(
      onResult: (text) {
        _currentText = text;
        notifyListeners();
      },
      onError: (error) {
        print('Erreur speech: $error');
        _retryCount++;
        
        // Circuit breaker : arrêter après trop d'échecs
        if (_retryCount >= _maxRetries) {
          print('Trop d\'échecs de reconnaissance vocale, mise en pause');
          _continuousListening = false;
          _setState(AssistantState.paused);
          return;
        }
        
        // Redémarrer avec délai progressif
        if (_continuousListening && 
            (error.contains('timeout') || error.contains('no_match'))) {
          final delay = Duration(seconds: _retryCount * 2); // Backoff exponentiel
          Future.delayed(delay, () {
            if (_continuousListening) {
              _restartListening();
            }
          });
        }
      }
    );
    
    // Programmer un redémarrage automatique si l'écoute s'arrête
    _restartTimer = Timer(const Duration(seconds: 25), () {
      if (_continuousListening && _state == AssistantState.listening) {
        _restartListening();
      }
    });
  }
  
  Future<void> _restartListening() async {
    if (!_continuousListening) return;
    
    // Si on a du texte, le traiter d'abord
    if (_currentText.isNotEmpty) {
      await _processUserInput(_currentText);
    } else {
      // Sinon redémarrer l'écoute directement
      await _speechService.stopListening();
      await Future.delayed(const Duration(milliseconds: 300));
      await _startContinuousListening();
    }
  }
  
  Future<void> startListening() async {
    if (!_isInitialized || _state == AssistantState.paused || !_continuousListening) return;
    await _startContinuousListening();
  }
  
  Future<void> stopListening() async {
    _restartTimer?.cancel();
    
    if (_state != AssistantState.listening) return;
    
    await _speechService.stopListening();
    
    if (_currentText.isNotEmpty && _continuousListening) {
      await _processUserInput(_currentText);
    } else if (!_continuousListening) {
      _setState(AssistantState.paused);
    } else {
      _setState(AssistantState.idle);
    }
  }
  
  Future<void> _processUserInput(String userInput) async {
    _restartTimer?.cancel();
    _setState(AssistantState.thinking);
    
    try {
      // Réinitialiser le compteur de retry en cas de succès
      _retryCount = 0;
      
      // Ajouter à l'historique avec limitation
      _conversationHistory.add('Vous: $userInput');
      _conversationHistory.add('Assistant: [En cours...]');
      
      // Limiter la taille de l'historique
      if (_conversationHistory.length > _maxHistoryItems) {
        _conversationHistory.removeRange(0, _conversationHistory.length - _maxHistoryItems);
      }
      
      // Formater le prompt avec le contexte
      String prompt = _aiService.formatPromptForAssistant(userInput);
      
      // Obtenir la réponse de l'IA
      String response = await _aiService.generateResponse(prompt);
      _lastResponse = response;
      
      // Remplacer le message temporaire
      _conversationHistory[_conversationHistory.length - 1] = 'Assistant: $response';
      
      // Parler la réponse
      _setState(AssistantState.speaking);
      await _speechService.speak(response);
      
      // Reprendre l'écoute automatiquement si en mode continu
      if (_continuousListening && _state != AssistantState.paused) {
        _setState(AssistantState.idle);
        await Future.delayed(const Duration(milliseconds: 500));
        await _startContinuousListening();
      } else {
        _setState(AssistantState.paused);
      }
    } catch (e) {
      _setState(AssistantState.error);
      print('Erreur lors du traitement: $e');
      
      // Redémarrer l'écoute même en cas d'erreur API
      if (_continuousListening) {
        await Future.delayed(const Duration(seconds: 2));
        _setState(AssistantState.idle);
        await _startContinuousListening();
      }
    }
    
    notifyListeners();
  }
  
  Future<void> stopSpeaking() async {
    await _speechService.stop();
    if (_continuousListening) {
      _setState(AssistantState.idle);
      await _startContinuousListening();
    } else {
      _setState(AssistantState.paused);
    }
    notifyListeners();
  }
  
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
    _restartTimer?.cancel();
    _speechService.dispose();
    super.dispose();
  }
}