import 'package:flutter/material.dart';
import 'dart:ui';

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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Bouton Caméra
            _buildControlButton(
              icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
              onPressed: onCameraPressed,
              backgroundColor: const Color(0xFF333333),
            ),
            
            // Bouton Partager/Upload
            _buildControlButton(
              icon: Icons.ios_share,
              onPressed: onSharePressed,
              backgroundColor: const Color(0xFF333333),
            ),
            
            // Bouton Pause/Play
            _buildControlButton(
              icon: isPaused ? Icons.play_circle_filled : Icons.pause_circle_filled,
              onPressed: onPausePressed,
              backgroundColor: const Color(0xFF333333),
            ),
            
            // Bouton Fermer (rouge)
            _buildControlButton(
              icon: Icons.close,
              onPressed: onClosePressed,
              backgroundColor: const Color(0xFFFF3B30),
              isCloseButton: true,
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
      onTapDown: (_) {
        // Effet de pression visuel
      },
      onTapUp: (_) {
        onPressed?.call();
      },
      onTapCancel: () {
        // Reset de l'effet de pression
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: isCloseButton ? 64 : 56,
        height: isCloseButton ? 40 : 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(isCloseButton ? 20 : 16),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isCloseButton ? 24 : 28,
        ),
      ),
    );
  }
}

