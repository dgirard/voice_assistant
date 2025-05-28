# Voice Assistant Flutter App

## Description
Assistant vocal intelligent développé en Flutter avec reconnaissance vocale, synthèse vocale et intégration Gemini AI. Interface moderne avec animations réactives et UX push-to-talk.

## Architecture
- **State Management**: Provider pattern
- **Voice Recognition**: speech_to_text package
- **Text-to-Speech**: flutter_tts package
- **AI Integration**: Google Gemini API avec historique conversationnel
- **UI Pattern**: Push-to-talk remplaçant l'écoute continue

## Fichiers Principaux
- `lib/providers/voice_assistant_provider.dart` - Gestion d'état principal
- `lib/services/ai_service.dart` - Intégration Gemini API
- `lib/widgets/voice_record_button.dart` - Bouton push-to-talk
- `lib/widgets/wave_animation.dart` - Animations réactives au microphone
- `lib/screens/voice_screen.dart` - Interface principale

## Commandes de Développement
```bash
# Installation des dépendances
flutter pub get

# Lancement en mode debug
flutter run

# Build pour Android
flutter build apk

# Déploiement sur appareil connecté
flutter run -d <device_id>

# Lancement sur émulateur
flutter emulators --launch <emulator_name>

# Tests
flutter test

# Analyse du code
flutter analyze
```

## Configuration
1. Créer fichier `.env` avec `GEMINI_API_KEY=your_key_here`
2. Ajouter permissions Android dans `android/app/src/main/AndroidManifest.xml`:
   - `RECORD_AUDIO`
   - `INTERNET`

## États de l'Assistant
- `idle` - En attente
- `listening` - Écoute en cours (push-to-talk actif)
- `thinking` - Traitement de la requête
- `speaking` - Réponse en cours
- `error` - Erreur rencontrée

## Fonctionnalités
- Push-to-talk pour démarrer l'enregistrement
- Interruption de la parole de l'assistant
- Animations d'ondes réactives aux niveaux sonores
- Historique conversationnel persistant
- Interface simplifiée et moderne
- Support multi-plateformes (Android, Web, Desktop)

## Notes de Déploiement
- **Pixel 7a**: Reconnaissance vocale fonctionnelle
- **Émulateur Android**: Limitations hardware pour reconnaissance vocale
- **Web**: Version disponible sur localhost:8080
- Créer émulateur avec Google Play Services: `flutter emulators --create --name pixel_with_play`