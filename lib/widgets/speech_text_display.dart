import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';

class SpeechTextDisplay extends StatefulWidget {
  const SpeechTextDisplay({Key? key}) : super(key: key);

  @override
  State<SpeechTextDisplay> createState() => _SpeechTextDisplayState();
}

class _SpeechTextDisplayState extends State<SpeechTextDisplay> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceAssistantProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Texte en cours de reconnaissance (toujours en haut)
                if (provider.currentText.isNotEmpty)
                  _buildCurrentQuestionWidget(context, provider),
                
                // Indicateur d'état avec animation de typing
                if (provider.state == AssistantState.thinking)
                  _buildThinkingIndicator(),
                
                // Dernière réponse de l'assistant (si pas en mode listening)
                if (provider.lastResponse.isNotEmpty && provider.state != AssistantState.listening) ...[
                  // Scroll vers le haut quand une nouvelle réponse arrive
                  Builder(builder: (context) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTop());
                    return _buildResponseWidget(provider.lastResponse);
                  }),
                ],
                
                // Historique des conversations (récent vers ancien)
                ..._buildConversationHistory(provider),
                
                // Instructions d'utilisation (seulement si pas d'historique)
                if (provider.state == AssistantState.idle && 
                    provider.currentText.isEmpty && 
                    provider.lastResponse.isEmpty &&
                    provider.conversationHistory.isEmpty)
                  _buildWelcomeMessage(),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _showEditDialog(BuildContext context, VoiceAssistantProvider provider) {
    final TextEditingController controller = TextEditingController(text: provider.currentText);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Éditer votre message',
            style: TextStyle(
              fontFamily: 'Chakra Petch',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            style: const TextStyle(
              fontFamily: 'Chakra Petch',
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Tapez votre message...',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF6B7FD7),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Annuler',
                style: TextStyle(
                  fontFamily: 'Chakra Petch',
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  provider.editCurrentText(controller.text.trim());
                  Navigator.of(context).pop();
                  // Envoyer automatiquement le message édité
                  provider.sendMessage();
                }
              },
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFF6B7FD7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Envoyer',
                style: TextStyle(
                  fontFamily: 'Chakra Petch',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// Widget pour la question en cours
  Widget _buildCurrentQuestionWidget(BuildContext context, VoiceAssistantProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Vous dites :',
                  style: TextStyle(
                    fontFamily: 'Chakra Petch',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (provider.state == AssistantState.readyToSend)
                GestureDetector(
                  onTap: () => _showEditDialog(context, provider),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 24,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            provider.currentText,
            style: const TextStyle(
              fontFamily: 'Chakra Petch',
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Widget pour l'indicateur de réflexion
  Widget _buildThinkingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'L\'assistant réfléchit',
            style: TextStyle(
              fontFamily: 'Chakra Petch',
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            height: 14,
            child: _TypingIndicator(),
          ),
        ],
      ),
    );
  }

  /// Widget pour une réponse d'assistant
  Widget _buildResponseWidget(String response) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3A4A9F).withOpacity(0.3),
            const Color(0xFF6B7FD7).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6B7FD7).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.android,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Assistant :',
                style: TextStyle(
                  fontFamily: 'Chakra Petch',
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            response,
            style: const TextStyle(
              fontFamily: 'Chakra Petch',
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Widget pour une question de l'historique
  Widget _buildQuestionWidget(String question) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person,
                color: Colors.white.withOpacity(0.6),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Vous :',
                style: TextStyle(
                  fontFamily: 'Chakra Petch',
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            question.replaceFirst('Vous: ', ''),
            style: const TextStyle(
              fontFamily: 'Chakra Petch',
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Widget pour une réponse de l'historique
  Widget _buildHistoryResponseWidget(String response) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3A4A9F).withOpacity(0.2),
            const Color(0xFF6B7FD7).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6B7FD7).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.android,
                color: Colors.white.withOpacity(0.6),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Assistant :',
                style: TextStyle(
                  fontFamily: 'Chakra Petch',
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            response.replaceFirst('Assistant: ', ''),
            style: const TextStyle(
              fontFamily: 'Chakra Petch',
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Construit l'historique des conversations (récent vers ancien)
  List<Widget> _buildConversationHistory(VoiceAssistantProvider provider) {
    final history = provider.conversationHistory;
    if (history.isEmpty) return [];

    List<Widget> widgets = [];
    
    // Parcourir l'historique en ordre inverse (récent vers ancien)
    // Exclure les 2 derniers éléments si ils correspondent à la conversation en cours
    int endIndex = history.length;
    if (history.length >= 2 &&
        provider.currentText.isNotEmpty &&
        provider.lastResponse.isNotEmpty) {
      // Vérifier si les 2 derniers éléments correspondent à la conversation actuelle
      final lastQuestion = history[history.length - 2];
      final lastResponse = history[history.length - 1];
      if (lastQuestion.contains(provider.currentText) && 
          lastResponse.contains(provider.lastResponse)) {
        endIndex = history.length - 2;
      }
    }
    
    // Traitement par paires (question, réponse) en ordre inverse
    for (int i = endIndex - 2; i >= 0; i -= 2) {
      if (i + 1 < endIndex) {
        final question = history[i];
        final response = history[i + 1];
        
        widgets.add(_buildQuestionWidget(question));
        widgets.add(_buildHistoryResponseWidget(response));
      }
    }
    
    return widgets;
  }

  /// Message de bienvenue
  Widget _buildWelcomeMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.mic,
            size: 48,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Maintenez le bouton pour enregistrer votre message',
            style: TextStyle(
              fontFamily: 'Chakra Petch',
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.33;
            final animationValue = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = (animationValue * 2).clamp(0.0, 1.0) - 
                           ((animationValue - 0.5) * 2).clamp(0.0, 1.0);
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: Text(
                '•',
                style: TextStyle(
                  fontFamily: 'Chakra Petch',
                  fontSize: 14,
                  color: Colors.white.withOpacity(opacity),
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}