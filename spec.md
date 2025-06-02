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
- ✅ **Décodage Unicode** : Conversion automatique des caractères échappés (\u627f → 承) pour affichage correct
- ✅ **Réponses TTS** : Suppression du contenu entre parenthèses pour améliorer la lecture vocale
- ✅ **Support multi-langues** : Affichage correct des caractères japonais, français et anglais
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

### 9. ✅ Support multi-langues
- ✅ **Langues supportées** : 7 langues (FR, EN, ES, DE, IT, JA, ZH)
- ✅ **Interface utilisateur** : Localisation complète avec ARB files (68+ clés traduites)
- ✅ **Sélecteur de langue** : Widget compact avec drapeaux dans écran principal
- ✅ **Services vocaux** : Reconnaissance et synthèse vocale dans chaque langue
- ✅ **Persistance** : Sauvegarde automatique de la langue sélectionnée
- ✅ **Configuration IA** : Prompts système adaptés à chaque langue
- ✅ **Localisation complète** : Tous les labels UI traduits (plus de hardcoding français)

### 10. ✅ Interface conversationnelle avancée
- ✅ **Historique persistant** : Conservation de toutes les conversations
- ✅ **Ordre chronologique inversé** : Affichage récent→ancien avec scroll automatique
- ✅ **Édition in-line** : Crayon repositionné en haut à droite (taille x1.5)
- ✅ **Reset sélectif** : Conservation historique sauf clic bouton rouge
- ✅ **Microphone optimisé** : 30s d'écoute continue, 8s de tolérance au silence
- ✅ **Scroll automatique** : Interface qui remonte lors de nouvelles réponses

### 11. ✅ Stabilité et robustesse
- ✅ **Reset complet** : Fonction de remise à zéro totale de l'application
- ✅ **Gestion mémoire** : Prévention des fuites avec timers et listeners
- ✅ **Lifecycle management** : Dispose approprié de tous les services
- ✅ **Race conditions** : Protection contre les appels concurrents
- ✅ **Error recovery** : Récupération automatique des erreurs services
- ✅ **TTS sans animation** : Affichage texte blanc simple pendant lecture

## ✅ Architecture technique implémentée

### ✅ Services
- ✅ **RaiseApiService** : Classe complète pour interactions Raise API avec gestion HTTP robuste
- ✅ **AiService** : Support des deux modes (Gemini/Raise) avec résumé automatique et décodage Unicode
- ✅ **SpeechService** : Reconnaissance vocale multi-langue avec réinitialisation sécurisée
- ✅ **AssistantPersistence** : Sauvegarde persistante avec SharedPreferences
- ✅ **TtsService** : Architecture dual TTS avec factory pattern et sélection voix intelligente
- ✅ **GeminiTtsTest** : Implémentation Gemini TTS basée sur code Spike
- ✅ **GeminiTtsTestPlugin** : Plugin Android natif pour lecture audio WAV
- ✅ **LanguageProvider** : Gestion centralisée des langues avec persistance

### ✅ État
- ✅ **AssistantType** : Enum (Gemini, Raise)
- ✅ **Assistant** : Modèle complet avec ID, nom, description, type
- ✅ **ThreadId** : Gestion automatique des threads Raise
- ✅ **VoiceAssistantProvider** : État centralisé avec support multi-assistant

### ✅ Interface
- ✅ **AssistantSelectionScreen** : Écran plein écran pour sélection d'assistant
- ✅ **ControlBar** : Icône d'assistant intégrée dans la barre du bas avec bouton reset
- ✅ **VoiceRecordButton** : Interaction simplifiée (clic unique) avec reset complet
- ✅ **SettingsScreen** : Configuration TTS avec sélecteur de moteur
- ✅ **GeminiTtsTestScreen** : Interface laboratoire pour test Gemini TTS
- ✅ **TtsEngineSelector** : Widget de sélection moteur TTS avec descriptions
- ✅ **LanguageSelector** : Widget de sélection de langue compact avec drapeaux

## ✅ Flux de données implémenté

### ✅ Initialisation
1. ✅ Chargement automatique de la langue sauvegardée avec application aux services vocaux
2. ✅ Chargement automatique du choix d'assistant persisté
3. ✅ Récupération asynchrone de la liste des assistants Raise
4. ✅ Configuration des services TTS/STT avec la langue restaurée
5. ✅ Affichage de l'icône d'assistant sélectionné avec fallback vers Gemini

### ✅ Conversation
1. ✅ **Gemini** : Envoi direct → Décodage Unicode → Réponse → Nettoyage parenthèses → TTS
2. ✅ **Raise** : 
   - Création/utilisation thread automatique → Interaction → Réponse
   - Décodage Unicode des caractères japonais/spéciaux
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
4. ✅ **Pendant traitement** : Clic pour reset complet de l'application
5. ✅ **Bouton croix rouge** : Reset complet (arrêt de tout + remise à zéro)

## ✅ Améliorations implémentées

### ✅ UX Avancée
- ✅ **Écran de sélection dédié** : Interface élégante avec descriptions et badges
- ✅ **Interaction simplifiée** : Remplacement du push-to-talk par clic simple
- ✅ **Multi-langues** : Interface utilisateur localisée (7 langues) avec sélecteur intégré
- ✅ **Historique conversationnel** : Persistant avec ordre chronologique inversé
- ✅ **Édition ergonomique** : Crayon d'édition en haut à droite (x1.5 taille)
- ✅ **Microphone tolérant** : 30s écoute, 8s silence (pas de coupure prématurée)
- ✅ **Reset application** : Fonction de remise à zéro complète accessible depuis boutons
- ✅ **Nettoyage TTS** : Suppression automatique des parenthèses pour une lecture fluide
- ✅ **Persistance transparente** : Choix d'assistant et langue sauvegardés automatiquement

### ✅ Gestion d'erreurs
- ✅ Fallback automatique vers Gemini en cas d'échec Raise
- ✅ Interface de chargement pendant récupération des assistants
- ✅ Gestion des timeouts et erreurs réseau avec retry intelligent
- ✅ Protection contre les race conditions dans services vocaux
- ✅ Récupération automatique des erreurs de reconnaissance vocale
- ✅ Messages d'erreur utilisateur-friendly

### ✅ Performance
- ✅ Chargement asynchrone des assistants Raise
- ✅ Cache automatique des threads actifs
- ✅ Optimisation des requêtes API avec annulation HTTP
- ✅ Gestion mémoire optimisée (timers, listeners, services)
- ✅ Initialisation des services avec ordre correct (langue → services)

## ✅ Statut final
**🎉 IMPLÉMENTATION COMPLÈTE ET STABLE**

Toutes les spécifications ont été implémentées avec succès, y compris les améliorations avancées :

### ✅ Fonctionnalités Core
- Support multi-assistant Gemini + Raise opérationnel
- Interface utilisateur moderne avec sélection d'assistant dédiée
- Support multi-langues complet (7 langues) avec persistance
- Historique conversationnel persistant avec scroll automatique
- Interactions vocales optimisées (30s écoute, 8s silence)
- Édition in-line avec crayon repositionné et agrandi
- Persistance automatique des préférences (assistant + langue + historique)

### ✅ Système TTS Avancé
- **Android TTS** : Service standard fiable et rapide avec sélection voix intelligente
- **Gemini AI TTS** : Service expérimental haute qualité
  - Voix adaptées par langue (Kore/Nova/Aura)
  - Génération audio 24kHz/16-bit
  - Plugin Android natif pour lecture optimisée
  - Fallback intelligent vers Android TTS

### ✅ Stabilité et Robustesse
- **Gestion mémoire** : Prévention complète des fuites (timers, listeners)
- **Race conditions** : Protection contre les appels concurrents
- **Error recovery** : Récupération automatique et fallbacks intelligents
- **Reset application** : Remise à zéro complète accessible depuis UI
- **Unicode support** : Affichage correct des caractères japonais/spéciaux

### ✅ Déploiement
L'application est déployée et opérationnelle sur Pixel 7a (34081JEHN11516) avec :
- Multi-assistant fonctionnel (Gemini + Raise)
- Support multi-langues complet (7 langues) avec services vocaux
- Historique conversationnel persistant avec interface optimisée
- Microphone avec timeouts optimisés (30s/8s)
- Édition in-line ergonomique (crayon agrandi, position haute droite)
- TTS dual engine opérationnel avec voix adaptées
- Interface utilisateur complète et intuitive
- Stabilité et performances optimisées

**État** : Prêt pour utilisation en production avec architecture robuste et stable.
**Version finale** : APK 19.7MB avec toutes les améliorations UX demandées.