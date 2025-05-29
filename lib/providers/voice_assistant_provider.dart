import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/speech_service.dart';
import '../services/ai_service.dart';
import '../services/assistant_persistence.dart';
import '../services/tts_service.dart';
import '../models/assistant.dart';
import '../models/language_config.dart';
import '../config/env_config.dart';
import 'language_provider.dart';
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
  
  // Support TTS multiple
  TtsEngine _currentTtsEngine = TtsEngine.android;
  late TtsService _ttsService;
  
  // Support multi-langue
  LanguageProvider? _languageProvider;
  
  // Gestion des timers pour éviter les fuites mémoire
  Timer? _errorTimer;
  Timer? _resetTimer;
  bool _isDisposed = false;
  
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
  
  // Getters et setters pour TTS
  TtsEngine get currentTtsEngine => _currentTtsEngine;
  
  void setTtsEngine(TtsEngine engine) {
    if (_currentTtsEngine != engine) {
      _currentTtsEngine = engine;
      _initializeTtsService();
      _saveTtsPreferences(); // Sauvegarder les préférences
      notifyListeners();
    }
  }
  
  void setLanguageProvider(LanguageProvider languageProvider) {
    // Retirer l'ancien listener si il existe
    _languageProvider?.removeListener(_onLanguageChanged);
    
    _languageProvider = languageProvider;
    _languageProvider?.addListener(_onLanguageChanged);
  }
  
  void _onLanguageChanged() {
    if (_languageProvider != null && _isInitialized) {
      final config = _languageProvider!.config;
      
      // Mettre à jour les services avec la nouvelle langue
      _speechService.updateLanguage(config.speechToTextLocale);
      _aiService.updateLanguageConfig(config);
      
      // Mettre à jour le service TTS seulement s'il est initialisé
      try {
        if (_ttsService is AndroidTtsService) {
          (_ttsService as AndroidTtsService).updateLanguage(config.ttsLanguage);
        } else if (_ttsService is GeminiTtsService) {
          (_ttsService as GeminiTtsService).updateLanguage(config.ttsLanguage);
        }
      } catch (e) {
        print('TTS service pas encore initialisé: $e');
      }
    }
  }
  
  Future<void> initialize() async {
    try {
      // S'assurer que la langue est restaurée avant d'initialiser les services vocaux
      if (_languageProvider != null) {
        // Attendre que la langue soit complètement restaurée
        await _languageProvider!.ensureLanguageLoaded();
        
        // Configurer la langue par défaut dans SpeechService AVANT l'initialisation
        final config = _languageProvider!.config;
        _speechService.setInitialLanguage(config.speechToTextLocale);
        _aiService.updateLanguageConfig(config);
      }
      
      _isInitialized = await _speechService.initialize();
      if (_isInitialized) {
        // Charger les préférences TTS sauvegardées
        await _loadTtsPreferences();
        
        // Initialiser le service TTS avec les préférences
        _initializeTtsService();
        
        // Appliquer la langue au TTS aussi
        if (_languageProvider != null) {
          final config = _languageProvider!.config;
          try {
            if (_ttsService is AndroidTtsService) {
              (_ttsService as AndroidTtsService).updateLanguage(config.ttsLanguage);
            } else if (_ttsService is GeminiTtsService) {
              (_ttsService as GeminiTtsService).updateLanguage(config.ttsLanguage);
            }
          } catch (e) {
            print('Erreur configuration TTS langue: $e');
          }
        }
        
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
    
    // Attendre que le speech-to-text finalise la transcription avec timeout
    int attempts = 0;
    const maxAttempts = 10; // Max 1 seconde (10 x 100ms)
    String lastText = _currentText;
    
    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
      
      // Si le texte a changé, attendre un peu plus pour la stabilisation
      if (_currentText != lastText) {
        lastText = _currentText;
        attempts = 0; // Reset pour donner plus de temps
      }
      
      // Si on a du texte et qu'il est stable, continuer
      if (_currentText.isNotEmpty && _currentText == lastText && attempts >= 3) {
        break;
      }
    }
    
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
    
    // Annuler le timer précédent s'il existe
    _errorTimer?.cancel();
    
    // Retour automatique à idle après 2 secondes
    _errorTimer = Timer(const Duration(seconds: 2), () {
      if (!_isDisposed && _state == AssistantState.error) {
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
      
      // Décoder les caractères Unicode échappés dans la réponse
      response = _decodeUnicodeEscapes(response);
      _lastResponse = response;
      
      // Remplacer le message temporaire
      _conversationHistory[_conversationHistory.length - 1] = 'Assistant: $response';
      
      // Nettoyer la réponse pour la synthèse vocale
      String cleanedResponse = _cleanResponseForTTS(response);
      
      // Parler la réponse nettoyée avec le moteur TTS sélectionné
      _setState(AssistantState.speaking);
      await _ttsService.speak(cleanedResponse);
      
      // Retour à l'état idle
      _setState(AssistantState.idle);
      
    } catch (e) {
      _setState(AssistantState.error);
      print('Erreur lors du traitement: $e');
      
      // Annuler le timer précédent s'il existe
      _errorTimer?.cancel();
      
      // Retour automatique à idle après erreur
      _errorTimer = Timer(const Duration(seconds: 3), () {
        if (!_isDisposed && _state == AssistantState.error) {
          _setState(AssistantState.idle);
          notifyListeners();
        }
      });
    }
    
    notifyListeners();
  }
  
  /// Arrêter la synthèse vocale
  Future<void> stopSpeaking() async {
    await _ttsService.stop();
    _setState(AssistantState.idle);
    notifyListeners();
  }
  
  /// Tester le moteur TTS actuel
  Future<void> testTtsEngine(String message) async {
    try {
      _setState(AssistantState.speaking);
      await _ttsService.speak(message);
      _setState(AssistantState.idle);
    } catch (e) {
      _setState(AssistantState.idle);
      print('Erreur test TTS: $e');
      rethrow;
    }
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
    // Éviter les appels concurrents
    if (_isLoadingAssistants) {
      return;
    }
    
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
      if (!_isDisposed) {
        notifyListeners();
      }
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

  // Décoder les caractères Unicode échappés (ex: \u627f -> 承)
  String _decodeUnicodeEscapes(String input) {
    return input.replaceAllMapped(
      RegExp(r'\\u([0-9a-fA-F]{4})'),
      (match) {
        try {
          final hexCode = match.group(1);
          if (hexCode != null) {
            final codePoint = int.parse(hexCode, radix: 16);
            return String.fromCharCode(codePoint);
          }
        } catch (e) {
          print('Erreur décodage Unicode: $e');
        }
        return match.group(0) ?? '';
      },
    );
  }

  // Nettoyer la réponse pour la synthèse vocale
  String _cleanResponseForTTS(String response) {
    // Note: Le décodage Unicode est maintenant fait en amont dans _processUserInput
    
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
  
  /// Initialiser le service TTS selon le moteur sélectionné
  void _initializeTtsService() {
    try {
      final geminiApiKey = EnvConfig.geminiApiKey;
      _ttsService = TtsServiceFactory.create(
        _currentTtsEngine,
        geminiApiKey: geminiApiKey,
      );
    } catch (e) {
      print('Erreur initialisation TTS: $e');
      // Fallback vers Android TTS en cas d'erreur
      _currentTtsEngine = TtsEngine.android;
      _ttsService = TtsServiceFactory.create(TtsEngine.android);
    }
  }

  /// Charger les préférences TTS sauvegardées
  Future<void> _loadTtsPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEngine = prefs.getString('tts_engine');
      
      if (savedEngine != null) {
        switch (savedEngine) {
          case 'android':
            _currentTtsEngine = TtsEngine.android;
            break;
          case 'gemini':
            _currentTtsEngine = TtsEngine.gemini;
            break;
          default:
            _currentTtsEngine = TtsEngine.android;
        }
        print('TTS engine chargé: $_currentTtsEngine');
      }
    } catch (e) {
      print('Erreur chargement préférences TTS: $e');
    }
  }

  /// Sauvegarder les préférences TTS
  Future<void> _saveTtsPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String engineString = _currentTtsEngine == TtsEngine.android ? 'android' : 'gemini';
      await prefs.setString('tts_engine', engineString);
      print('TTS engine sauvegardé: $engineString');
    } catch (e) {
      print('Erreur sauvegarde préférences TTS: $e');
    }
  }

  /// Reset complet de l'application - revenir à l'état initial
  Future<void> resetToInitialState() async {
    try {
      print('🔄 Reset complet de l\'application...');
      
      // 1. Arrêter immédiatement tous les services actifs
      await _stopAllActiveServices();
      
      // 2. Annuler toutes les requêtes HTTP en cours
      await _cancelAllHttpRequests();
      
      // 3. Réinitialiser tous les états
      _resetAllStates();
      
      // 4. Réinitialiser les services
      await _reinitializeServices();
      
      print('✅ Reset complet terminé');
      notifyListeners();
      
    } catch (e) {
      print('❌ Erreur lors du reset: $e');
      _setState(AssistantState.error);
      
      // Annuler le timer précédent s'il existe  
      _resetTimer?.cancel();
      
      // Retour automatique à idle après erreur
      _resetTimer = Timer(const Duration(seconds: 2), () {
        if (!_isDisposed && _state == AssistantState.error) {
          _setState(AssistantState.idle);
          notifyListeners();
        }
      });
    }
  }
  
  /// Arrêter tous les services actifs immédiatement
  Future<void> _stopAllActiveServices() async {
    // Arrêter la reconnaissance vocale
    if (_speechService.isListening) {
      await _speechService.stopListening();
    }
    
    // Arrêter la synthèse vocale
    await _ttsService.stop();
    
    // Arrêter le speech service
    await _speechService.stop();
  }
  
  /// Annuler toutes les requêtes HTTP en cours
  Future<void> _cancelAllHttpRequests() async {
    // Annuler toutes les requêtes AI en cours
    _aiService.cancelAllRequests();
    
    // Empêcher les retry
    _retryCount = _maxRetries;
  }
  
  /// Réinitialiser tous les états à leurs valeurs par défaut
  void _resetAllStates() {
    _state = AssistantState.idle;
    _currentText = '';
    _lastResponse = '';
    _conversationHistory.clear();
    _isRecording = false;
    _retryCount = 0;
    _currentSoundLevel = 0.0;
    _currentThreadId = null; // Reset du thread Raise
  }
  
  /// Réinitialiser les services dans leur état de démarrage
  Future<void> _reinitializeServices() async {
    // Le speech service est déjà initialisé, pas besoin de re-initialiser
    // Juste s'assurer qu'il est dans un état propre
    if (!_speechService.speechEnabled) {
      await _speechService.initialize();
    }
    
    // Reset du service AI pour remettre _isCancelled à false
    _aiService.reset();
    
    // Le TTS service est déjà configuré
    // Pas besoin de le réinitialiser
  }

  @override
  void dispose() {
    _isDisposed = true;
    
    // Annuler tous les timers pour éviter les fuites mémoire
    _errorTimer?.cancel();
    _resetTimer?.cancel();
    
    // Nettoyer les services
    _speechService.dispose();
    _ttsService.dispose();
    _languageProvider?.removeListener(_onLanguageChanged);
    
    super.dispose();
  }
}