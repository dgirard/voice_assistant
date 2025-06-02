# Voice Assistant Flutter App

## Description
Assistant vocal intelligent développé en Flutter avec support multi-assistant (Gemini + Raise), système TTS avancé (Android + Gemini AI), support multi-langues complet (7 langues), historique conversationnel persistant, et interface moderne avec animations réactives. Architecture robuste avec gestion mémoire optimisée et reset complet de l'application.

## Architecture
- **State Management**: Provider pattern avec SharedPreferences pour persistance multi-préférences
- **Voice Recognition**: speech_to_text package avec timeouts optimisés (30s écoute, 8s silence)
- **Text-to-Speech**: Système dual (flutter_tts + Gemini AI TTS avec plugin Android natif)
- **AI Integration**: Multi-assistant (Gemini API + Raise API) avec résumé automatique et décodage Unicode
- **Internationalization**: flutter_localizations avec ARB files (FR/EN/ES/DE/IT/JA/ZH)
- **Conversation History**: Historique persistant avec ordre chronologique inversé et scroll automatique
- **Memory Management**: Gestion robuste des timers, listeners et lifecycle
- **UI Pattern**: Interface conversationnelle avec édition in-line et reset sélectif

## Fichiers Principaux
- `lib/providers/voice_assistant_provider.dart` - Gestion d'état principal multi-assistant
- `lib/services/ai_service.dart` - Intégration multi-API (Gemini + Raise) avec résumé
- `lib/services/raise_api_service.dart` - Service API Raise pour assistants spécialisés
- `lib/services/tts_service.dart` - Services TTS dual (Android + Gemini AI)
- `lib/services/gemini_tts_test.dart` - Implémentation TTS Gemini avancée
- `lib/services/speech_service.dart` - Reconnaissance vocale avec timeouts optimisés
- `lib/widgets/voice_record_button.dart` - Bouton clic simple
- `lib/widgets/speech_text_display.dart` - Affichage historique conversationnel avec édition
- `lib/widgets/wave_animation.dart` - Animations réactives au microphone
- `lib/screens/voice_screen.dart` - Interface principale
- `lib/screens/assistant_selection_screen.dart` - Sélection d'assistant
- `lib/screens/settings_screen.dart` - Configuration TTS
- `lib/l10n/app_*.arb` - Fichiers de traduction (7 langues)
- `android/app/src/main/kotlin/com/example/voice_assistant/GeminiTtsTestPlugin.kt` - Plugin Android pour TTS Gemini

## Commandes de Développement
```bash
# Installation des dépendances
flutter pub get

# Lancement en mode debug
flutter run

# Build pour Android
flutter build apk

# Déploiement sur appareil connecté (Pixel 7a)
flutter run --release -d 34081JEHN11516

# Lancement sur émulateur
flutter emulators --launch <emulator_name>

# Tests
flutter test

# Analyse du code
flutter analyze

# Nettoyage build
flutter clean && flutter pub get
```

## Configuration
1. Créer fichier `.env` avec:
   - `GEMINI_API_KEY=your_key_here`
   - `RAISE_API_KEY=your_key_here` (optionnel)
2. Ajouter permissions Android dans `android/app/src/main/AndroidManifest.xml`:
   - `RECORD_AUDIO`
   - `INTERNET`
   - `WRITE_EXTERNAL_STORAGE` (pour TTS Gemini)

## États de l'Assistant
- `idle` - En attente
- `listening` - Écoute en cours (push-to-talk actif)
- `thinking` - Traitement de la requête
- `speaking` - Réponse en cours
- `error` - Erreur rencontrée

## Fonctionnalités
- **Multi-assistant**: Support Gemini (général) + Raise (spécialisés)
- **TTS avancé**: Android TTS standard + Gemini AI TTS expérimental
- **Microphone optimisé**: 30s d'écoute continue, 8s de tolérance au silence
- **Historique conversationnel**: Persistant avec ordre chronologique inversé (récent→ancien)
- **Édition in-line**: Crayon repositionné en haut à droite (taille x1.5)
- **Scroll automatique**: Interface qui remonte lors de nouvelles réponses
- **Reset sélectif**: Conservation historique sauf clic bouton rouge
- **Multi-langues**: 7 langues complètement traduites (FR/EN/ES/DE/IT/JA/ZH)
- **Sélection d'assistant**: Écran dédié avec persistance automatique
- **Résumé automatique**: Réponses Raise longues résumées par Gemini
- **Interruption**: Arrêt de la parole de l'assistant
- **Animations**: Ondes réactives aux niveaux sonores sans animation TTS
- **Interface moderne**: Design sombre avec transitions fluides
- **Support multi-plateformes**: Android, Web, Desktop

## Notes de Déploiement
- **Pixel 7a (34081JEHN11516)**: Reconnaissance vocale et TTS Gemini fonctionnels
- **Émulateur Android**: Limitations hardware pour reconnaissance vocale et TTS Gemini
- **Web**: Version disponible sur localhost:8080 (TTS Gemini non supporté)
- **Android SDK**: Minimum 21, compilé avec SDK 33 pour compatibilité plugins
- **Kotlin**: Version 1.8+ requise pour plugins TTS avancés
- Créer émulateur avec Google Play Services: `flutter emulators --create --name pixel_with_play`

## Architecture TTS
- **Android TTS**: Service standard fiable via flutter_tts
- **Gemini AI TTS**: Service expérimental via API REST + plugin Android natif
  - Génération audio via Gemini API (model: gemini-2.5-flash-preview-tts)
  - Création fichiers WAV avec headers corrects
  - Lecture via MediaPlayer Android natif
  - Fallback automatique vers Android TTS en cas d'erreur

## Interface Conversationnelle
### Affichage Historique (ordre récent → ancien)
```
[Question en cours]     ← Toujours en haut avec crayon d'édition
[Réponse en cours]      ← Juste en dessous
─────────────────────
Question précédente 3   ← Plus récente
Réponse assistant 3
Question précédente 2   
Réponse assistant 2
Question précédente 1   ← Plus ancienne
Réponse assistant 1
[Plus d'historique...]
```

### Paramètres Microphone Optimisés
- **listenFor**: 30 secondes (durée totale d'écoute)
- **pauseFor**: 8 secondes (tolérance au silence)
- **Comportement**: Pas de coupure prématurée, pauses naturelles respectées

## États et Flux
- **idle**: En attente d'interaction utilisateur
- **listening**: Enregistrement vocal en cours (30s max, 8s silence)
- **readyToSend**: Texte transcrit avec option d'édition (crayon en haut à droite)
- **thinking**: Traitement de la requête par l'assistant
- **speaking**: Réponse vocale en cours de lecture (texte blanc simple)
- **error**: Erreur avec fallback automatique

## Gestion Historique
- **Persistance**: Toutes les conversations conservées
- **Scroll**: Automatique vers le haut lors de nouvelles réponses
- **Effacement**: Uniquement via bouton rouge avec croix
- **Édition**: Crayon x1.5 en position haute droite