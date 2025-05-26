# 🔐 Configuration des clés API

## 📋 **Prérequis**

1. **Clé API Gemini** (gratuite)
   - Rendez-vous sur [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Créez un compte Google si nécessaire
   - Cliquez sur "Create API Key"
   - Copiez la clé générée

## ⚙️ **Configuration locale**

### 1. Créer le fichier de configuration

```bash
# Copier le template
cp .env.example .env
```

### 2. Ajouter votre clé API

Éditez le fichier `.env` et remplacez `your_actual_gemini_api_key_here` par votre vraie clé :

```env
GEMINI_API_KEY=AIzaSyC8WiRnxdjNdxGcjhsdfghjklzxcvbnm
APP_NAME=Voice Assistant
DEBUG_MODE=true
```

### 3. Installer les dépendances

```bash
flutter pub get
```

### 4. Lancer l'application

```bash
flutter run
```

## 🛡️ **Sécurité**

### ✅ **Ce qui est sécurisé :**
- Le fichier `.env` est **exclu de Git** (`.gitignore`)
- Les clés ne sont **jamais committées** dans le code
- **Validation automatique** au démarrage de l'app
- **Messages d'erreur clairs** si la clé manque

### ❌ **Ce qu'il ne faut JAMAIS faire :**
- Committer le fichier `.env` 
- Mettre des clés directement dans le code
- Partager ses clés par email/chat
- Utiliser la même clé en prod et dev

## 🚀 **Déploiement production**

### Variables d'environnement CI/CD :
```bash
# GitHub Actions
GEMINI_API_KEY=${{ secrets.GEMINI_API_KEY }}

# Firebase App Distribution
flutter build apk --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
```

### Build avec clé :
```bash
flutter build apk --dart-define=GEMINI_API_KEY=your_key_here
```

## 🔍 **Dépannage**

### Erreur "Configuration Error" :
1. Vérifiez que `.env` existe
2. Vérifiez que `GEMINI_API_KEY` est défini
3. Redémarrez l'application
4. Vérifiez les logs de la console

### Erreur "API key not valid" :
1. Vérifiez que la clé est correcte
2. Testez la clé sur [AI Studio](https://makersuite.google.com/)
3. Régénérez une nouvelle clé si nécessaire

### Erreur de chargement :
```bash
flutter clean
flutter pub get
flutter run
```