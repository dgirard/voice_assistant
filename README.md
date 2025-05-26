# 🎤 Voice Assistant Flutter

Un assistant vocal moderne avec animations fluides inspiré de Gemini, développé en Flutter.

## ✨ Fonctionnalités

- 🎙️ **Push-to-Talk** - Maintenez le bouton pour enregistrer
- 🤖 **Intelligence artificielle** - Intégration API Gemini 1.5 Flash
- 🔊 **Synthèse vocale** - Text-to-speech pour les réponses
- 🌊 **Animations fluides** - Vagues bleues réactives au son
- 📱 **Design moderne** - Interface sombre style Gemini
- 🔐 **Configuration sécurisée** - Variables d'environnement pour API

## 🎨 Interface

L'application reproduit fidèlement le design des assistants vocaux modernes :

- **Barre d'application** : Icônes navigation + indicateur "Live"
- **Animation vagues** : Dégradé bleu qui réagit à l'amplitude vocale
- **Bouton central** : Enregistrement push-to-talk avec feedback visuel
- **Zone principale** : Fond noir avec transitions fluides
- **Barre contrôle** : Caméra, partage, fermeture

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

3. **Configurer l'API Gemini**
```bash
# Créer le fichier .env à la racine du projet
echo "GEMINI_API_KEY=VOTRE_CLE_API_GEMINI" > .env
```

4. **Lancer l'application**
```bash
flutter run
```

## 📦 Dépendances

- `speech_to_text` - Reconnaissance vocale
- `flutter_tts` - Synthèse vocale  
- `permission_handler` - Gestion permissions
- `provider` - Gestion d'état
- `http` - Requêtes API
- `flutter_dotenv` - Variables d'environnement sécurisées

## 🏗️ Architecture

```
lib/
├── main.dart                 # Point d'entrée
├── providers/                # Gestion d'état
│   └── voice_assistant_provider.dart
├── services/                 # Services métier
│   ├── speech_service.dart   # Reconnaissance/synthèse vocale
│   └── ai_service.dart       # Intégration IA
├── screens/                  # Écrans
│   └── voice_screen.dart     # Écran principal
└── widgets/                  # Composants UI
    ├── wave_animation.dart   # Animation vagues
    ├── voice_record_button.dart # Bouton push-to-talk
    ├── speech_text_display.dart # Affichage texte
    ├── custom_app_bar.dart   # Barre d'application
    └── control_bar.dart      # Barre de contrôle
```

## 🎯 Utilisation

1. **Maintenir** : Appuyez et maintenez le bouton central
2. **Parler** : Enregistrez votre message vocal
3. **Relâcher** : Le message est envoyé automatiquement à l'IA
4. **Écouter** : L'assistant répond vocalement avec animation

## 🔧 Configuration API

### Gemini API
1. Obtenez une clé sur [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Remplacez `YOUR_GEMINI_API_KEY` dans `ai_service.dart`

## 📱 Permissions

### Android
- `RECORD_AUDIO` - Enregistrement microphone
- `INTERNET` - Accès réseau

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