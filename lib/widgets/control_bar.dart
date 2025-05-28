import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';
import '../models/assistant.dart';

class ControlBar extends StatelessWidget {
  final VoidCallback? onCameraPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onPausePressed;
  final VoidCallback? onClosePressed;
  final bool isPaused;
  final bool isCameraOn;

  const ControlBar({
    Key? key,
    this.onCameraPressed,
    this.onSharePressed,
    this.onPausePressed,
    this.onClosePressed,
    this.isPaused = false,
    this.isCameraOn = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 34), // Espace pour la barre de navigation gestuelle
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF202025).withOpacity(0.7),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            // Icône d'assistant à gauche
            Expanded(
              flex: 1,
              child: Consumer<VoiceAssistantProvider>(
                builder: (context, provider, child) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/assistant-selection');
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B7FD7),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B7FD7).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          provider.selectedAssistant.type == AssistantType.gemini
                              ? Icons.psychology
                              : Icons.smart_toy,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Boutons à droite
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Bouton Caméra
                  Flexible(
                    child: _buildControlButton(
                      icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
                      onPressed: onCameraPressed,
                      backgroundColor: const Color(0xFF333333),
                    ),
                  ),
                  
                  // Bouton Partager/Upload
                  Flexible(
                    child: _buildControlButton(
                      icon: Icons.ios_share,
                      onPressed: onSharePressed,
                      backgroundColor: const Color(0xFF333333),
                    ),
                  ),
                  
                  // Bouton Fermer (rouge)
                  Flexible(
                    child: _buildControlButton(
                      icon: Icons.close,
                      onPressed: onClosePressed,
                      backgroundColor: const Color(0xFFFF3B30),
                      isCloseButton: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    bool isCloseButton = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isCloseButton ? 40 : 36,
        height: isCloseButton ? 28 : 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(isCloseButton ? 14 : 10),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: isCloseButton ? 16 : 18,
          ),
        ),
      ),
    );
  }
}

