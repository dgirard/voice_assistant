# Implémentation TTS Multi-Moteur

Cette implémentation propose deux options de synthèse vocale pour l'assistant vocal Flutter.

## 📋 Vue d'ensemble

L'application supporte maintenant deux moteurs TTS :

### Option 1: **Android TTS Standard** (Recommandée) ✅
- **Avantages** : Gratuit, latence faible, fonctionne hors ligne, intégration système optimisée
- **Inconvénients** : Qualité vocale standard, voix moins naturelles
- **Utilisation** : Production, utilisation quotidienne

### Option 2: **Gemini AI TTS** (Expérimental) 🧪
- **Avantages** : Voix très naturelle, meilleure prononciation, intonation intelligente
- **Inconvénients** : Requiert internet, latence plus élevée, coût API
- **Utilisation** : Démonstration, cas d'usage premium

## 🏗️ Architecture

```
lib/services/
├── tts_service.dart           # Interface et factory
├── speech_service.dart        # Service existant (reconnaissance vocale)
└── ...

lib/widgets/
├── tts_engine_selector.dart   # Sélecteur d'interface
└── ...

lib/screens/
├── settings_screen.dart       # Écran de configuration
└── ...

android/app/src/main/kotlin/
└── GeminiTtsPlugin.kt        # Plugin natif pour audio WAV
```

## 🔧 Configuration

### Android TTS (Aucune configuration)
Utilise le moteur TTS natif Android. Fonctionne immédiatement.

### Gemini AI TTS
1. **API Key** : Ajouter `GEMINI_API_KEY` dans `.env`
2. **Modèle** : Utilise `gemini-2.5-flash-preview-tts`
3. **Format audio** : WAV 24kHz, 16-bit, mono
4. **Plugin natif** : Lecture audio via AudioTrack Android

## 📱 Interface utilisateur

### Accès aux paramètres
- **Bouton paramètres** dans la barre de contrôle
- **Écran dédié** avec sélecteur visuel
- **Test de voix** intégré

### Sélection du moteur
```dart
// Changer de moteur programmatiquement
provider.setTtsEngine(TtsEngine.android);
provider.setTtsEngine(TtsEngine.gemini);

// Tester le moteur actuel
await provider.testTtsEngine("Message de test");
```

## 🔀 Basculement automatique

En cas d'erreur avec Gemini TTS :
1. **Fallback automatique** vers Android TTS
2. **Notification utilisateur** de l'erreur
3. **Continuité de service** assurée

## 💡 Code Python de référence

Voici le code Python original adapté pour Flutter :

```python
# Code Python original
from google import genai
from google.genai import types
import wave

client = genai.Client(api_key="GEMINI_API_KEY")

response = client.models.generate_content(
    model="gemini-2.5-flash-preview-tts",
    contents="Say cheerfully: Have a wonderful day!",
    config=types.GenerateContentConfig(
        response_modalities=["AUDIO"],
        speech_config=types.SpeechConfig(
            voice_config=types.VoiceConfig(
                prebuilt_voice_config=types.PrebuiltVoiceConfig(
                    voice_name='Kore',
                )
            )
        ),
    )
)

data = response.candidates[0].content.parts[0].inline_data.data
```

## 🚀 Utilisation

### 1. Sélection du moteur
```dart
// Dans l'écran de paramètres
TtsEngineSelector(
  currentEngine: provider.currentTtsEngine,
  onEngineChanged: (engine) {
    provider.setTtsEngine(engine);
  },
)
```

### 2. Synthèse vocale
```dart
// Le provider gère automatiquement le moteur sélectionné
await provider._ttsService.speak("Votre message");
```

### 3. Test de qualité
```dart
// Test intégré dans l'écran de paramètres
await provider.testTtsEngine("Message de test");
```

## 🛠️ Dépendances ajoutées

### Flutter
```yaml
# Aucune dépendance supplémentaire requise
# Utilise les packages existants : flutter_tts, http
```

### Android
```kotlin
// build.gradle
implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4"
```

## 📊 Comparaison des moteurs

| Critère | Android TTS | Gemini AI TTS |
|---------|-------------|---------------|
| **Coût** | Gratuit | Payant (API) |
| **Latence** | <100ms | 500-2000ms |
| **Qualité** | Standard | Supérieure |
| **Connectivité** | Hors ligne | Internet requis |
| **Langues** | Multiples | Limitées |
| **Personnalisation** | Basique | Avancée |

## 🔒 Sécurité

- **API Key** stockée dans variables d'environnement
- **Validation** des réponses avant lecture
- **Fallback** automatique en cas d'échec
- **Timeout** configuré pour les requêtes

## 🧪 Tests

### Test automatisé
```dart
// Test unitaire du factory
final service = TtsServiceFactory.create(TtsEngine.android);
expect(service, isA<AndroidTtsService>());
```

### Test utilisateur
- **Bouton test** dans l'écran de paramètres
- **Message standardisé** pour comparaison
- **Gestion d'erreur** intégrée

## 📈 Monitoring

### Métriques suggérées
- Latence de synthèse par moteur
- Taux de succès/échec
- Préférence utilisateur (Android vs Gemini)
- Coût API Gemini

### Logs
```dart
print('TTS Engine: $_currentTtsEngine');
print('Synthesis time: ${duration}ms');
print('Error fallback to Android TTS');
```

## 🔄 Migration

### Depuis l'ancien système
1. **Remplacement progressif** de `flutter_tts` direct
2. **Conservation** de la compatibilité existante  
3. **Interface unified** via `TtsService`

### Ajout de nouveaux moteurs
```dart
// Extensible via l'enum et le factory
enum TtsEngine { android, gemini, azure, aws }

class TtsServiceFactory {
  static TtsService create(TtsEngine engine, {Map<String, String>? config}) {
    switch (engine) {
      case TtsEngine.android: return AndroidTtsService();
      case TtsEngine.gemini: return GeminiTtsService();
      case TtsEngine.azure: return AzureTtsService();
      // ...
    }
  }
}
```

## 📝 Notes de développement

### Choix de conception
- **Pattern Factory** pour l'extensibilité
- **Interface commune** pour la simplicité
- **Fallback automatique** pour la robustesse
- **Configuration centralisée** dans le provider

### Limitations actuelles
- **Gemini TTS** en preview (API peut changer)
- **Format audio** fixe (WAV 24kHz)
- **Voix limitées** pour Gemini
- **Pas de cache** audio (streaming uniquement)

### Améliorations futures
- **Cache audio** pour répétitions
- **Voix personnalisées** Gemini
- **Équaliseur audio** intégré
- **Métriques temps réel**