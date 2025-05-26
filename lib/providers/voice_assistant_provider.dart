import 'package:flutter/foundation.dart';
import '../services/speech_service.dart';
import '../services/ai_service.dart';

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
  
  AssistantState get state => _state;
  String get currentText => _currentText;
  String get lastResponse => _lastResponse;
  List<String> get conversationHistory => _conversationHistory;
  bool get isInitialized => _isInitialized;
  bool get isListening => _speechService.isListening;
  
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
  
  Future<void> startListening() async {
    if (!_isInitialized) return;
    
    _setState(AssistantState.listening);
    _currentText = '';
    
    await _speechService.startListening(
      onResult: (text) {
        _currentText = text;
        notifyListeners();
      }
    );
  }
  
  Future<void> stopListening() async {
    if (_state != AssistantState.listening) return;
    
    await _speechService.stopListening();
    
    if (_currentText.isNotEmpty) {
      await _processUserInput(_currentText);
    } else {
      _setState(AssistantState.idle);
    }
  }
  
  Future<void> _processUserInput(String userInput) async {
    _setState(AssistantState.thinking);
    
    try {
      // Ajouter à l'historique
      _conversationHistory.add('Vous: $userInput');
      
      // Formater le prompt avec le contexte
      String prompt = _aiService.formatPromptForAssistant(userInput);
      
      // Obtenir la réponse de l'IA
      String response = await _aiService.generateResponse(prompt);
      _lastResponse = response;
      _conversationHistory.add('Assistant: $response');
      
      // Parler la réponse
      _setState(AssistantState.speaking);
      await _speechService.speak(response);
      
      _setState(AssistantState.idle);
    } catch (e) {
      _setState(AssistantState.error);
      print('Erreur lors du traitement: $e');
    }
    
    notifyListeners();
  }
  
  Future<void> stopSpeaking() async {
    await _speechService.stop();
    _setState(AssistantState.idle);
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
    _speechService.dispose();
    super.dispose();
  }
}