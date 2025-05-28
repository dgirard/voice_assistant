# 🎤 Voice Assistant Flutter

Un assistant vocal moderne avec support multi-assistant (Gemini + Raise) et système TTS avancé, développé en Flutter.

## ✨ Fonctionnalités

- 🎙️ **Clic simple** - Démarrage/arrêt d'enregistrement en un clic
- 🤖 **Multi-assistant** - Support Gemini AI et assistants Raise spécialisés
- 🔊 **TTS avancé** - Android TTS standard + Gemini AI TTS expérimental
- 🌊 **Animations fluides** - Vagues bleues réactives au son
- 📱 **Design moderne** - Interface sombre style Gemini avec sélection d'assistant
- 🔐 **Configuration sécurisée** - Variables d'environnement pour API
- 💾 **Persistance** - Sauvegarde automatique des préférences utilisateur

## 🎨 Interface

L'application reproduit fidèlement le design des assistants vocaux modernes :

- **Barre d'application** : Icônes navigation + indicateur "Live"
- **Animation vagues** : Dégradé bleu qui réagit à l'amplitude vocale
- **Bouton central** : Enregistrement clic simple avec feedback visuel
- **Zone principale** : Fond noir avec transitions fluides
- **Barre contrôle** : Icône assistant, paramètres, caméra, partage, fermeture
- **Écran sélection** : Interface dédiée pour choisir l'assistant (Gemini/Raise)
- **Écran paramètres** : Configuration TTS (Android standard vs Gemini AI)

## 🚀 Installation

### Prérequis
- Flutter SDK >= 2.17.0
- Android SDK 21+ / iOS 11+
- Clé API Gemini

### Configuration

1. **Cloner le projet**
```bash
git clone https://github.com/dgirard/voice_assistant.git
cd voice_assistant
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configurer les APIs**
```bash
# Créer le fichier .env à la racine du projet
echo "GEMINI_API_KEY=VOTRE_CLE_API_GEMINI" > .env
echo "RAISE_API_KEY=VOTRE_CLE_API_RAISE" >> .env
```

4. **Lancer l'application**
```bash
flutter run
```

## 📦 Dépendances

- `speech_to_text` - Reconnaissance vocale
- `flutter_tts` - Synthèse vocale Android
- `permission_handler` - Gestion permissions
- `provider` - Gestion d'état
- `http` - Requêtes API
- `flutter_dotenv` - Variables d'environnement sécurisées
- `shared_preferences` - Persistance des préférences
- `path_provider` - Accès système de fichiers pour TTS Gemini
- `cupertino_icons` - Icônes iOS style

## 🏗️ Architecture

```
lib/
├── main.dart                 # Point d'entrée
├── providers/                # Gestion d'état
│   └── voice_assistant_provider.dart
├── services/                 # Services métier
│   ├── speech_service.dart   # Reconnaissance vocale
│   ├── ai_service.dart       # Intégration IA multi-assistant
│   ├── raise_api_service.dart # API Raise pour assistants spécialisés
│   ├── tts_service.dart      # Services TTS (Android + Gemini)
│   └── gemini_tts_test.dart  # Implémentation TTS Gemini avancée
├── screens/                  # Écrans
│   ├── voice_screen.dart     # Écran principal
│   ├── assistant_selection_screen.dart # Sélection d'assistant
│   ├── settings_screen.dart  # Paramètres TTS
│   └── gemini_tts_test_screen.dart # Test laboratoire Gemini TTS
└── widgets/                  # Composants UI
    ├── wave_animation.dart   # Animation vagues
    ├── voice_record_button.dart # Bouton clic simple
    ├── speech_text_display.dart # Affichage texte
    ├── custom_app_bar.dart   # Barre d'application
    ├── control_bar.dart      # Barre de contrôle
    └── tts_engine_selector.dart # Sélecteur moteur TTS
```

## 🎯 Utilisation

### Assistant vocal
1. **Cliquer** : Un clic sur le bouton central démarre l'enregistrement
2. **Parler** : Enregistrez votre message vocal
3. **Cliquer** : Un second clic envoie le message à l'assistant sélectionné
4. **Écouter** : L'assistant répond vocalement avec animation

### Sélection d'assistant
1. **Icône assistant** : Cliquez sur l'icône dans la barre du bas
2. **Choisir** : Sélectionnez Gemini (général) ou un assistant Raise (spécialisé)
3. **Retour automatique** : L'écran principal se restaure avec le nouvel assistant

### Configuration TTS
1. **Paramètres** : Accédez via l'icône paramètres
2. **Moteur TTS** : Choisissez Android TTS (standard) ou Gemini AI TTS (expérimental)
3. **Test** : Testez la voix sélectionnée avant utilisation

## 🔧 Configuration API

### Gemini API
1. Obtenez une clé sur [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Ajoutez `GEMINI_API_KEY=votre_clé` dans le fichier `.env`

### Raise API (optionnel)
1. Obtenez une clé API Raise auprès de SFEIR
2. Ajoutez `RAISE_API_KEY=votre_clé` dans le fichier `.env`
3. Les assistants Raise spécialisés seront automatiquement disponibles

## 📱 Permissions

### Android
- `RECORD_AUDIO` - Enregistrement microphone
- `INTERNET` - Accès réseau
- `WRITE_EXTERNAL_STORAGE` - Stockage fichiers audio temporaires (TTS Gemini)

### iOS  
- `NSMicrophoneUsageDescription` - Utilisation microphone
- `NSSpeechRecognitionUsageDescription` - Reconnaissance vocale

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :

1. Fork le projet
2. Créer une branche feature
3. Commit vos changements
4. Ouvrir une Pull Request

## 📄 Licence

MIT License - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🙏 Remerciements

- Design inspiré de Google Gemini
- Communauté Flutter pour les packages
- Contributors et testeurs

---

🔗 **Repository** : [github.com/dgirard/voice_assistant](https://github.com/dgirard/voice_assistant)