# Spécifications - Multi-Assistant Voice Interface

## Vue d'ensemble
Extension de l'assistant vocal Flutter pour supporter plusieurs types d'assistants :
- **Gemini** : Assistant général (fonctionnement actuel)
- **Raise** : Assistants spécialisés et groundés par domaine

## Fonctionnalités à implémenter

### 1. Sélection d'assistant
- Récupération des assistants Raise via `GET /v2/assistants/`
- Filtrage des assistants contenant "#Voice" dans le nom
- Affichage du nom sans le préfixe "#Voice"
- Interface de sélection dans la barre du bas

### 2. Configuration API
- **Variable d'environnement** : `RAISE_API_KEY` dans `.env`
- **Base URL** : `https://raise.sfeir.com`
- **Headers requis** :
  - `X-API-Key`: [RAISE_API_KEY]
  - `Content-Type`: `application/json`

### 3. Interface utilisateur
- **Emplacement du sélecteur** : Barre du bas (avec bouton microphone)
- **Affichage de l'assistant actuel** : Nom visible (sans "#Voice")
- **Persistance** : Sauvegarde du choix entre les sessions
- **UX** : Maintien du push-to-talk existant

### 4. Logique conditionnelle

#### Mode Gemini (actuel)
- Conversation directe avec l'API Gemini
- Historique conversationnel maintenu
- Aucun changement du fonctionnement existant

#### Mode Raise (nouveau)
- **Création de thread** : `POST /v2/threads`
  ```json
  {
    "name": "Voice Conversation [timestamp]",
    "assistant_id": "[selected_assistant_id]"
  }
  ```
- **Interaction** : `POST /v2/interact/invocation`
  ```json
  {
    "assistant_id": "[assistant_id]",
    "message": "[user_message]",
    "thread_id": "[thread_id]"
  }
  ```
- **Réponse** : Extraction du champ `llm_output`

### 5. Gestion des réponses longues
- **Condition** : Si réponse Raise > 100 mots
- **Action** : Résumé via API Gemini
- **Prompt de résumé** :
  ```
  "Résume ce texte en exactement 100 mots maximum pour une réponse vocale, en gardant les informations les plus importantes comme les noms propres : [texte]"
  ```
- **Usage** : Le résumé remplace la réponse originale pour la synthèse vocale

### 6. Gestion des conversations
- **Nouvelle conversation Gemini** : Vider l'historique conversationnel
- **Nouvelle conversation Raise** : Créer un nouveau thread avec l'assistant sélectionné
- **Changement d'assistant** : 
  - Si passage à Gemini : Vider historique
  - Si passage à Raise : Créer nouveau thread

### 7. Nettoyage des réponses
Application du nettoyage pour les réponses Raise :
- Suppression des caractères échappés (`\"`, `\\n`)
- Conversion des codes Unicode (`\\u00e9` → `é`)
- Normalisation des espaces multiples

## Architecture technique

### Services
- **RaiseApiService** : Nouvelle classe pour interactions Raise API
- **AiService** : Modification pour supporter les deux modes
- **AssistantPersistence** : Sauvegarde du choix d'assistant

### État
- **AssistantType** : Enum (Gemini, Raise)
- **SelectedAssistant** : Modèle avec ID, nom, type
- **ThreadId** : Stockage pour conversations Raise actives

### Interface
- **AssistantSelector** : Widget de sélection dans la barre du bas
- **AssistantIndicator** : Affichage de l'assistant actuel
- **BottomBar** : Réorganisation pour inclure le sélecteur

## Flux de données

### Initialisation
1. Chargement du choix d'assistant persisté
2. Si Raise : Récupération de la liste des assistants
3. Affichage de l'assistant sélectionné

### Conversation
1. **Gemini** : Envoi direct → Réponse → TTS
2. **Raise** : 
   - Création/utilisation thread → Interaction → Réponse
   - Si > 100 mots : Résumé Gemini → TTS
   - Sinon : TTS direct

### Changement d'assistant
1. Sauvegarde du nouveau choix
2. Réinitialisation de la conversation
3. Mise à jour de l'interface

## Points d'attention
- Gestion des erreurs API Raise
- Fallback vers Gemini en cas d'échec Raise
- Performance : Cache des assistants Raise
- UX : Indicateur de chargement lors du changement
- Sécurité : Validation des réponses avant TTS