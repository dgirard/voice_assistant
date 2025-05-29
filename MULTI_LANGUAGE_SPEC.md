# 🌐 Spécification : Application Voice Assistant Multi-Langue

## 📋 Vue d'ensemble

Transformation de l'assistant vocal pour supporter **Français, Anglais et Japonais** avec adaptation automatique du STT, TTS et IA selon la langue sélectionnée.

## 🎯 Objectifs

- **Sélection de langue** : Interface utilisateur pour choisir parmi FR/EN/JA
- **STT adaptatif** : Reconnaissance vocale dans la langue sélectionnée
- **TTS adaptatif** : Synthèse vocale avec voix native de la langue
- **IA contextuelle** : Prompts et réponses dans la langue appropriée
- **UI localisée** : Interface traduite selon la langue

## 🔍 Analyse de l'Existant

### **Problèmes Identifiés**
- STT hardcodé sur `"fr-FR"` (speech_service.dart:64)
- TTS hardcodé sur `"fr-FR"` (tts_service.dart:28)
- Prompts IA en français uniquement (ai_service.dart:74-75)
- 22 fichiers avec texte français non-externalisé
- Aucune infrastructure i18n (pas de flutter_localizations)

### **Sécurité Vérifiée**
✅ Aucune clé API dans le code source  
✅ Fichiers .env exclus de Git  
✅ Configuration sécurisée via dotenv

## 🏗️ Architecture Proposée

### 1. **Gestion d'État Linguistique**

```dart
class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('fr', 'FR');
  LanguageConfig _config = LanguageConfig.french();
  
  // Locales supportés
  static const supportedLocales = [
    Locale('fr', 'FR'), // Français
    Locale('en', 'US'), // Anglais
    Locale('ja', 'JP'), // Japonais
  ];
  
  Future<void> changeLanguage(Locale locale) async {
    _currentLocale = locale;
    _config = LanguageConfig.fromLocale(locale);
    
    // Persistence
    await SharedPreferences.getInstance()
        .then((prefs) => prefs.setString('language', locale.toLanguageTag()));
    
    // Notification services
    await _updateServices();
    notifyListeners();
  }
}
```

### 2. **Configuration Linguistique**

```dart
class LanguageConfig {
  final String speechToTextLocale;
  final String ttsLanguage;
  final String aiSystemPrompt;
  final String aiSummarizePrompt;
  
  // Configurations prédéfinies
  static LanguageConfig french() => LanguageConfig(
    speechToTextLocale: 'fr-FR',
    ttsLanguage: 'fr-FR',
    aiSystemPrompt: 'Tu es un assistant vocal intelligent...',
    aiSummarizePrompt: 'Résume ce texte en français...',
  );
  
  static LanguageConfig english() => LanguageConfig(
    speechToTextLocale: 'en-US',
    ttsLanguage: 'en-US',
    aiSystemPrompt: 'You are an intelligent voice assistant...',
    aiSummarizePrompt: 'Summarize this text in English...',
  );
  
  static LanguageConfig japanese() => LanguageConfig(
    speechToTextLocale: 'ja-JP',
    ttsLanguage: 'ja-JP',
    aiSystemPrompt: 'あなたは賢い音声アシスタントです...',
    aiSummarizePrompt: 'このテキストを日本語で要約してください...',
  );
}
```

### 3. **Services Adaptés**

#### **SpeechService Multi-Langue**
```dart
class SpeechService {
  String _currentLocale = 'fr-FR';
  
  Future<void> updateLanguage(String localeId) async {
    _currentLocale = localeId;
    // Reconfigurer sans redémarrer
    await _speechToText.cancel();
  }
  
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onError,
    Function(double)? onSoundLevelChange,
  }) async {
    await _speechToText.listen(
      localeId: _currentLocale, // Dynamique
      // ... autres paramètres
    );
  }
}
```

#### **TtsService Multi-Langue**
```dart
class TtsService {
  String _currentLanguage = 'fr-FR';
  
  Future<void> updateLanguage(String language) async {
    _currentLanguage = language;
    await _flutterTts.setLanguage(_currentLanguage);
    
    // Sélection voix optimale pour la langue
    await _selectBestVoice();
  }
  
  Future<void> _selectBestVoice() async {
    final voices = await _flutterTts.getVoices;
    final bestVoice = voices.firstWhere(
      (voice) => voice['locale'].startsWith(_currentLanguage.split('-')[0]),
      orElse: () => voices.first,
    );
    await _flutterTts.setVoice(bestVoice);
  }
}
```

#### **AIService Multi-Langue**
```dart
class AIService {
  LanguageConfig _languageConfig = LanguageConfig.french();
  
  void updateLanguageConfig(LanguageConfig config) {
    _languageConfig = config;
  }
  
  Future<String> _generateGeminiResponse(String prompt, [List<String>? conversationHistory]) async {
    final contents = [
      {
        'role': 'user',
        'parts': [{'text': _languageConfig.aiSystemPrompt}] // Prompt localisé
      },
      // ... reste de la conversation
    ];
    // ...
  }
  
  Future<String> _summarizeWithGemini(String text) async {
    final summarizePrompt = _languageConfig.aiSummarizePrompt + text;
    return _generateGeminiResponse(summarizePrompt, null);
  }
}
```

### 4. **Interface Utilisateur**

#### **Sélecteur de Langue**
```dart
class LanguageSelector extends StatelessWidget {
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return DropdownButton<Locale>(
          value: languageProvider.currentLocale,
          items: [
            DropdownMenuItem(
              value: const Locale('fr', 'FR'),
              child: Row(children: [
                Text('🇫🇷'),
                SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.french),
              ]),
            ),
            DropdownMenuItem(
              value: const Locale('en', 'US'),
              child: Row(children: [
                Text('🇺🇸'),
                SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.english),
              ]),
            ),
            DropdownMenuItem(
              value: const Locale('ja', 'JP'),
              child: Row(children: [
                Text('🇯🇵'),
                SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.japanese),
              ]),
            ),
          ],
          onChanged: (locale) {
            if (locale != null) {
              languageProvider.changeLanguage(locale);
            }
          },
        );
      },
    );
  }
}
```

## 📁 Structure de Fichiers

```
lib/
├── l10n/                           # Internationalisation
│   ├── app_en.arb                 # Anglais
│   ├── app_fr.arb                 # Français
│   ├── app_ja.arb                 # Japonais
│   └── l10n.dart                  # Configuration i18n
├── models/
│   └── language_config.dart       # Configuration langue
├── providers/
│   ├── language_provider.dart     # État linguistique
│   └── voice_assistant_provider.dart # Mis à jour
├── services/
│   ├── speech_service.dart        # STT multi-langue
│   ├── tts_service.dart           # TTS multi-langue
│   └── ai_service.dart            # IA multi-langue
├── widgets/
│   ├── language_selector.dart     # Sélecteur langue
│   └── ... (widgets existants mis à jour)
└── screens/
    └── ... (écrans avec i18n)
```

## 🔧 Modifications Techniques

### 1. **pubspec.yaml**
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0
  
flutter:
  generate: true
  assets:
    - assets/l10n/
```

### 2. **flutter_gen/l10n.yaml**
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

### 3. **Fichiers de Traduction**

#### **app_fr.arb**
```json
{
  "appTitle": "Assistant Vocal",
  "ready": "Prêt à vous écouter",
  "listening": "Je vous écoute...",
  "thinking": "Je réfléchis...",
  "speaking": "Je réponds...",
  "french": "Français",
  "english": "Anglais",
  "japanese": "Japonais",
  "settings": "Paramètres",
  "testVoice": "Tester la voix",
  "newConversation": "Nouvelle conversation démarrée",
  "connectionError": "Erreur de connexion",
  "pressToStart": "Appuyez sur le bouton microphone pour commencer"
}
```

#### **app_en.arb**
```json
{
  "appTitle": "Voice Assistant",
  "ready": "Ready to listen",
  "listening": "I'm listening...",
  "thinking": "Thinking...",
  "speaking": "Speaking...",
  "french": "French",
  "english": "English", 
  "japanese": "Japanese",
  "settings": "Settings",
  "testVoice": "Test Voice",
  "newConversation": "New conversation started",
  "connectionError": "Connection error",
  "pressToStart": "Press the microphone button to start"
}
```

#### **app_ja.arb**
```json
{
  "appTitle": "音声アシスタント",
  "ready": "聞く準備ができました",
  "listening": "聞いています...",
  "thinking": "考えています...",
  "speaking": "話しています...",
  "french": "フランス語",
  "english": "英語",
  "japanese": "日本語",
  "settings": "設定",
  "testVoice": "音声テスト",
  "newConversation": "新しい会話を開始しました",
  "connectionError": "接続エラー",
  "pressToStart": "マイクボタンを押して開始してください"
}
```

## 🚀 Plan d'Implémentation

### **Phase 1 : Infrastructure (2-3 jours)**
1. ✅ Ajouter dépendances i18n (pubspec.yaml)
2. ✅ Créer LanguageProvider et LanguageConfig
3. ✅ Configurer fichiers ARB avec traductions
4. ✅ Mise à jour MaterialApp avec supportedLocales

### **Phase 2 : Services (2-3 jours)**
1. ✅ Adapter SpeechService pour multi-langue
2. ✅ Adapter TtsService avec sélection voix automatique
3. ✅ Adapter AIService avec prompts localisés
4. ✅ Tests de basculement langue en temps réel

### **Phase 3 : UI (2-3 jours)**
1. ✅ Externaliser toutes les chaînes UI (22 fichiers)
2. ✅ Créer LanguageSelector widget avec drapeaux
3. ✅ Intégrer sélecteur dans settings_screen
4. ✅ Persistence préférences langue (SharedPreferences)

### **Phase 4 : Tests & Polish (1-2 jours)**
1. ✅ Tests STT/TTS dans les 3 langues
2. ✅ Tests prompts IA localisés
3. ✅ Tests transitions langue sans redémarrage
4. ✅ Validation UX et animations

## 🎮 Expérience Utilisateur

1. **Sélection initiale** : Détection automatique locale système
2. **Changement manuel** : Sélecteur dans paramètres avec drapeaux
3. **Persistence** : Mémorisation choix utilisateur
4. **Transition fluide** : Basculement sans redémarrage app
5. **Feedback visuel** : Animation pendant changement langue
6. **Cohérence** : STT + TTS + IA + UI dans la même langue

## 🔍 Points d'Attention

### **Technique**
- **Qualité STT** : Vérifier support japonais sur appareils physiques
- **Voix TTS** : Sélection automatique des meilleures voix par langue
- **Prompts IA** : Adaptation culturelle des prompts système
- **Performance** : Basculement langue sans latence

### **UX**
- **Détection auto** : Respecter préférences système utilisateur
- **Feedback** : Indiquer langue active dans l'interface
- **Erreurs** : Messages d'erreur dans la langue sélectionnée
- **Cohérence** : Même langue pour parole et interface

### **Tests Requis**
- ✅ Tests unitaires pour LanguageProvider
- ✅ Tests services STT/TTS multi-langues
- ✅ Tests prompts IA localisés
- ✅ Tests basculement langue en temps réel
- ✅ Tests persistence préférences

## 📊 Estimation

- **Effort total** : 7-10 jours développement
- **Complexité** : Moyenne (refactoring étendu)
- **Risques** : Support japonais STT sur certains appareils
- **Bénéfices** : Application accessible à un public international

Cette architecture permet une expérience multilingue complète avec adaptation automatique de tous les composants selon la langue sélectionnée, tout en maintenant la fluidité et les performances de l'application existante.