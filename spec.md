# Spécifications - Multi-Assistant Voice Interface avec TTS Avancé

## Vue d'ensemble
Assistant vocal Flutter supportant plusieurs types d'assistants et système TTS dual :
- **Assistants** : Gemini (général) + Raise (spécialisés)
- **TTS** : Android standard + Gemini AI expérimental
- **Interface** : Moderne avec sélection dédiée et configuration TTS

## ✅ Fonctionnalités implémentées

### 1. ✅ Sélection d'assistant
- ✅ Récupération des assistants Raise via `GET /v2/assistants/`
- ✅ Filtrage des assistants contenant "#Voice" dans le nom
- ✅ Affichage du nom sans le préfixe "#Voice"
- ✅ **Écran de sélection dédié** (au lieu d'un sélecteur dans la barre)
- ✅ **Icône d'assistant** dans la barre du bas pour accéder à la sélection

### 2. ✅ Configuration API
- ✅ **Variable d'environnement** : `RAISE_API_KEY` dans `.env`
- ✅ **Base URL** : `https://raise.sfeir.com`
- ✅ **Headers requis** :
  - `X-API-Key`: [RAISE_API_KEY]
  - `Content-Type`: `application/json`

### 3. ✅ Interface utilisateur
- ✅ **Icône d'assistant** : Barre du bas (côté gauche)
- ✅ **Écran de sélection** : Interface plein écran avec liste élégante
- ✅ **Affichage de l'assistant actuel** : Icône distinctive par type
- ✅ **Persistance** : Sauvegarde du choix entre les sessions avec SharedPreferences
- ✅ **UX simplifiée** : Clic simple pour démarrer/arrêter l'enregistrement

### 4. ✅ Logique conditionnelle

#### ✅ Mode Gemini
- ✅ Conversation directe avec l'API Gemini
- ✅ Historique conversationnel maintenu
- ✅ Fonctionnement existant préservé

#### ✅ Mode Raise
- ✅ **Création de thread** : `POST /v2/threads`
  ```json
  {
    "name": "Voice Conversation [timestamp]",
    "assistant_id": "[selected_assistant_id]"
  }
  ```
- ✅ **Interaction** : `POST /v2/interact/invocation`
  ```json
  {
    "assistant_id": "[assistant_id]",
    "message": "[user_message]",
    "thread_id": "[thread_id]"
  }
  ```
- ✅ **Réponse** : Extraction du champ `llm_output`

### 5. ✅ Gestion des réponses longues
- ✅ **Condition** : Si réponse Raise > 100 mots
- ✅ **Action** : Résumé automatique via API Gemini
- ✅ **Prompt de résumé** :
  ```
  "Résume ce texte en exactement 100 mots maximum pour une réponse vocale, en gardant les informations les plus importantes comme les noms propres : [texte]"
  ```
- ✅ **Usage** : Le résumé remplace la réponse originale pour la synthèse vocale

### 6. ✅ Gestion des conversations
- ✅ **Nouvelle conversation Gemini** : Vider l'historique conversationnel
- ✅ **Nouvelle conversation Raise** : Créer un nouveau thread avec l'assistant sélectionné
- ✅ **Changement d'assistant** : 
  - Si passage à Gemini : Vider historique
  - Si passage à Raise : Créer nouveau thread

### 7. ✅ Nettoyage des réponses
- ✅ **Réponses Raise** : Suppression des caractères échappés et Unicode
- ✅ **Réponses TTS** : Suppression du contenu entre parenthèses pour améliorer la lecture vocale
- ✅ **Normalisation** : Espaces multiples et trim automatique

### 8. ✅ Système TTS avancé
- ✅ **Dual TTS Engine** : Android TTS standard + Gemini AI TTS expérimental
- ✅ **Sélecteur TTS** : Interface utilisateur pour choisir le moteur vocal
- ✅ **Gemini TTS avancé** : Intégration complète basée sur système de test
  - API Gemini 2.5 Flash Preview TTS
  - Génération fichiers WAV avec headers corrects
  - Plugin Android natif pour lecture MediaPlayer
  - Fallback automatique vers Android TTS
- ✅ **Test laboratoire** : Interface de test complète pour Gemini TTS
- ✅ **Configuration SDK** : Android SDK 33 pour compatibilité plugins

## ✅ Architecture technique implémentée

### ✅ Services
- ✅ **RaiseApiService** : Classe complète pour interactions Raise API
- ✅ **AiService** : Support des deux modes (Gemini/Raise) avec résumé automatique
- ✅ **AssistantPersistence** : Sauvegarde persistante avec SharedPreferences
- ✅ **TtsService** : Architecture dual TTS avec factory pattern
- ✅ **GeminiTtsTest** : Implémentation Gemini TTS basée sur code Spike
- ✅ **GeminiTtsTestPlugin** : Plugin Android natif pour lecture audio WAV

### ✅ État
- ✅ **AssistantType** : Enum (Gemini, Raise)
- ✅ **Assistant** : Modèle complet avec ID, nom, description, type
- ✅ **ThreadId** : Gestion automatique des threads Raise
- ✅ **VoiceAssistantProvider** : État centralisé avec support multi-assistant

### ✅ Interface
- ✅ **AssistantSelectionScreen** : Écran plein écran pour sélection d'assistant
- ✅ **ControlBar** : Icône d'assistant intégrée dans la barre du bas
- ✅ **VoiceRecordButton** : Interaction simplifiée (clic unique)
- ✅ **SettingsScreen** : Configuration TTS avec sélecteur de moteur
- ✅ **GeminiTtsTestScreen** : Interface laboratoire pour test Gemini TTS
- ✅ **TtsEngineSelector** : Widget de sélection moteur TTS avec descriptions

## ✅ Flux de données implémenté

### ✅ Initialisation
1. ✅ Chargement automatique du choix d'assistant persisté
2. ✅ Récupération asynchrone de la liste des assistants Raise
3. ✅ Affichage de l'icône d'assistant sélectionné avec fallback vers Gemini

### ✅ Conversation
1. ✅ **Gemini** : Envoi direct → Réponse → Nettoyage parenthèses → TTS
2. ✅ **Raise** : 
   - Création/utilisation thread automatique → Interaction → Réponse
   - Si > 100 mots : Résumé Gemini automatique → TTS
   - Sinon : Nettoyage → TTS direct

### ✅ Changement d'assistant
1. ✅ Sauvegarde automatique du nouveau choix
2. ✅ Réinitialisation automatique de la conversation (historique/thread)
3. ✅ Mise à jour immédiate de l'interface et retour à l'écran principal

### ✅ Interaction vocale
1. ✅ **Clic 1** : Démarre l'enregistrement vocal
2. ✅ **Clic 2** : Arrête l'enregistrement et envoie le message
3. ✅ **Pendant réponse** : Clic pour interrompre la synthèse vocale

## ✅ Améliorations implémentées

### ✅ UX Avancée
- ✅ **Écran de sélection dédié** : Interface élégante avec descriptions et badges
- ✅ **Interaction simplifiée** : Remplacement du push-to-talk par clic simple
- ✅ **Nettoyage TTS** : Suppression automatique des parenthèses pour une lecture fluide
- ✅ **Persistance transparente** : Choix d'assistant sauvegardé automatiquement

### ✅ Gestion d'erreurs
- ✅ Fallback automatique vers Gemini en cas d'échec Raise
- ✅ Interface de chargement pendant récupération des assistants
- ✅ Gestion des timeouts et erreurs réseau
- ✅ Messages d'erreur utilisateur-friendly

### ✅ Performance
- ✅ Chargement asynchrone des assistants Raise
- ✅ Cache automatique des threads actifs
- ✅ Optimisation des requêtes API

## ✅ Statut final
**🎉 IMPLÉMENTATION COMPLÈTE ET FONCTIONNELLE**

Toutes les spécifications ont été implémentées avec succès, y compris les améliorations TTS avancées :

### ✅ Fonctionnalités Core
- Support multi-assistant Gemini + Raise opérationnel
- Interface utilisateur moderne avec sélection d'assistant dédiée
- Interactions vocales simplifiées (clic unique)
- Persistance automatique des préférences

### ✅ Système TTS Avancé
- **Android TTS** : Service standard fiable et rapide
- **Gemini AI TTS** : Service expérimental haute qualité
  - Voix naturelle "Kore" (française)
  - Génération audio 24kHz/16-bit
  - Plugin Android natif pour lecture optimisée
  - Fallback intelligent vers Android TTS

### ✅ Déploiement
L'application est déployée et opérationnelle sur Pixel 7a (34081JEHN11516) avec :
- Multi-assistant fonctionnel (Gemini + Raise)
- TTS dual engine opérationnel
- Interface utilisateur complète et intuitive
- Performances optimisées et gestion d'erreur robuste

**État** : Prêt pour utilisation en production avec système TTS avancé intégré.