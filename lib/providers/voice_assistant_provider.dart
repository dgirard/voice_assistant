import 'package:flutter/foundation.dart';
import '../services/speech_service.dart';
import '../services/ai_service.dart';
import '../services/assistant_persistence.dart';
import '../models/assistant.dart';
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
  
  // Nouveaux champs pour multi-assistant
  Assistant _selectedAssistant = Assistant.gemini();
  List<Assistant> _availableAssistants = [];
  String? _currentThreadId;
  bool _isLoadingAssistants = false;
  
  AssistantState get state => _state;
  String get currentText => _currentText;
  String get lastResponse => _lastResponse;
  List<String> get conversationHistory => _conversationHistory;
  bool get isInitialized => _isInitialized;
  bool get isListening => _speechService.isListening;
  bool get isRecording => _isRecording;
  double get currentSoundLevel => _currentSoundLevel;
  
  // Nouveaux getters pour multi-assistant
  Assistant get selectedAssistant => _selectedAssistant;
  List<Assistant> get availableAssistants => _availableAssistants;
  bool get isLoadingAssistants => _isLoadingAssistants;
  
  Future<void> initialize() async {
    try {
      _isInitialized = await _speechService.initialize();
      if (_isInitialized) {
        _setState(AssistantState.idle);
        
        // Charger l'assistant sélectionné depuis les préférences
        await _loadSelectedAssistant();
        
        // Charger la liste des assistants disponibles
        await _loadAvailableAssistants();
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
      
      // Obtenir la réponse de l'IA selon le type d'assistant
      String response;
      if (_selectedAssistant.type == AssistantType.gemini) {
        response = await _aiService.generateResponse(
          prompt,
          conversationHistory: _conversationHistory,
        );
      } else {
        // Assistant Raise - créer un thread si nécessaire
        _currentThreadId ??= await _aiService.createRaiseThread(_selectedAssistant);
        
        response = await _aiService.generateResponse(
          prompt,
          assistant: _selectedAssistant,
          threadId: _currentThreadId,
        );
      }
      _lastResponse = response;
      
      // Remplacer le message temporaire
      _conversationHistory[_conversationHistory.length - 1] = 'Assistant: $response';
      
      // Nettoyer la réponse pour la synthèse vocale
      String cleanedResponse = _cleanResponseForTTS(response);
      
      // Parler la réponse nettoyée
      _setState(AssistantState.speaking);
      await _speechService.speak(cleanedResponse);
      
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
    
    // Reset du thread pour assistants Raise
    if (_selectedAssistant.type == AssistantType.raise) {
      _currentThreadId = null;
    }
    
    notifyListeners();
  }

  // Nouvelles méthodes pour la gestion multi-assistant
  
  Future<void> _loadSelectedAssistant() async {
    final savedAssistant = await AssistantPersistence.getSelectedAssistant();
    if (savedAssistant != null) {
      _selectedAssistant = savedAssistant;
    }
  }

  Future<void> _loadAvailableAssistants() async {
    _isLoadingAssistants = true;
    notifyListeners();
    
    try {
      _availableAssistants = await _aiService.getAvailableAssistants();
      
      // Vérifier si l'assistant sélectionné est toujours disponible
      final isSelectedAvailable = _availableAssistants.any(
        (assistant) => assistant.id == _selectedAssistant.id && 
                      assistant.type == _selectedAssistant.type
      );
      
      if (!isSelectedAvailable) {
        // Fallback vers Gemini si l'assistant sélectionné n'est plus disponible
        _selectedAssistant = Assistant.gemini();
        await AssistantPersistence.saveSelectedAssistant(_selectedAssistant);
      }
    } catch (e) {
      print('Erreur lors du chargement des assistants: $e');
      _availableAssistants = [Assistant.gemini()];
    } finally {
      _isLoadingAssistants = false;
      notifyListeners();
    }
  }

  Future<void> selectAssistant(Assistant assistant) async {
    if (_selectedAssistant == assistant) return;
    
    final previousAssistant = _selectedAssistant;
    _selectedAssistant = assistant;
    
    // Sauvegarder le choix
    await AssistantPersistence.saveSelectedAssistant(assistant);
    
    // Nouvelle conversation si changement d'assistant
    clearHistory();
    
    // Si passage d'un assistant Raise à un autre, reset le thread
    if (previousAssistant.type == AssistantType.raise || 
        assistant.type == AssistantType.raise) {
      _currentThreadId = null;
    }
    
    notifyListeners();
  }

  Future<void> refreshAssistants() async {
    await _loadAvailableAssistants();
  }

  // Nettoyer la réponse pour la synthèse vocale
  String _cleanResponseForTTS(String response) {
    // Supprimer tout ce qui est entre parenthèses
    String cleaned = response.replaceAll(RegExp(r'\([^)]*\)'), '');
    
    // Supprimer les marqueurs markdown en préservant le contenu
    cleaned = cleaned
        // Gras **texte** - garder seulement le texte
        .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) => match.group(1) ?? '')
        .replaceAllMapped(RegExp(r'__(.*?)__'), (match) => match.group(1) ?? '')
        // Italique *texte* - attention aux conflits avec les listes
        .replaceAllMapped(RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)'), (match) => match.group(1) ?? '')
        .replaceAllMapped(RegExp(r'(?<!_)_([^_]+)_(?!_)'), (match) => match.group(1) ?? '')
        // Code `texte`
        .replaceAllMapped(RegExp(r'`([^`]*)`'), (match) => match.group(1) ?? '')
        // Liens [texte](url) - garder seulement le texte
        .replaceAllMapped(RegExp(r'\[([^\]]*)\]\([^)]*\)'), (match) => match.group(1) ?? '')
        // Barré ~~texte~~
        .replaceAllMapped(RegExp(r'~~(.*?)~~'), (match) => match.group(1) ?? '')
        // Titres # ## ### etc. - enlever seulement les #
        .replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '')
        // Listes - ou * ou + - enlever seulement les puces
        .replaceAll(RegExp(r'^[\s]*[-*+]\s+', multiLine: true), '')
        // Listes numérotées 1. 2. etc.
        .replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '')
        // Citations >
        .replaceAll(RegExp(r'^>\s*', multiLine: true), '')
        // Code blocks ``` - supprimer entièrement
        .replaceAll(RegExp(r'```[^`]*```', dotAll: true), '');
    
    // Supprimer les caractères indésirables d'abord
    cleaned = cleaned
        .replaceAll(RegExp(r'[\$]+'), '') // Supprimer les $ qui trainent
        .replaceAll(RegExp(r'\*+'), '') // Supprimer les * isolés
        .replaceAll(RegExp(r'"+'), '') // Supprimer les " isolés
        .replaceAll(RegExp(r'\s+'), ' ') // Puis nettoyer les espaces multiples
        .trim();
    
    return cleaned;
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