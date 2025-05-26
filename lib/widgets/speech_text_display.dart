import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';

class SpeechTextDisplay extends StatelessWidget {
  const SpeechTextDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceAssistantProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // Texte en cours de reconnaissance
              if (provider.currentText.isNotEmpty)
                Container(
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
                      Text(
                        'Vous dites :',
                        style: TextStyle(
                          fontFamily: 'Chakra Petch',
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
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
                ),
              
              // Dernière réponse de l'assistant
              if (provider.lastResponse.isNotEmpty && provider.state != AssistantState.listening)
                Container(
                  padding: const EdgeInsets.all(20),
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
                        provider.lastResponse,
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
                ),
              
              // Indicateur d'état avec animation de typing
              if (provider.state == AssistantState.thinking)
                Container(
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
                ),
              
              // Instructions d'utilisation
              if (provider.state == AssistantState.paused && provider.currentText.isEmpty && provider.lastResponse.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.play_circle_filled,
                        size: 48,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Appuyez sur le bouton play pour activer l\'écoute continue',
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
                ),
              
              // État d'écoute active
              if (provider.state == AssistantState.idle && provider.continuousListening)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.mic,
                        size: 48,
                        color: Colors.blue.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'En écoute... Parlez maintenant',
                        style: TextStyle(
                          fontFamily: 'Chakra Petch',
                          fontSize: 16,
                          color: Colors.blue.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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