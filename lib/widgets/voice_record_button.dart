import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';

class VoiceRecordButton extends StatefulWidget {
  const VoiceRecordButton({Key? key}) : super(key: key);

  @override
  State<VoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<VoiceRecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceAssistantProvider>(
      builder: (context, provider, child) {
        // Gérer les animations selon l'état
        _updateAnimation(provider.state);

        return GestureDetector(
          onTapDown: (_) => _onPressStart(provider),
          onTapUp: (_) => _onPressEnd(provider),
          onTapCancel: () => _onPressEnd(provider),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _getGradientForState(provider.state),
                  boxShadow: [
                    BoxShadow(
                      color: _getColorForState(provider.state).withOpacity(0.4),
                      blurRadius: 25 * _pulseAnimation.value,
                      spreadRadius: 8 * _pulseAnimation.value,
                    ),
                  ],
                ),
                transform: Matrix4.identity()
                  ..scale(_scaleAnimation.value),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconForState(provider.state),
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getTextForState(provider.state),
                      style: const TextStyle(
                        fontFamily: 'Chakra Petch',
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _updateAnimation(AssistantState state) {
    switch (state) {
      case AssistantState.listening:
        _animationController.repeat(reverse: true);
        break;
      case AssistantState.thinking:
      case AssistantState.speaking:
        _animationController.forward();
        break;
      default:
        _animationController.stop();
        _animationController.reset();
    }
  }

  void _onPressStart(VoiceAssistantProvider provider) async {
    if (provider.state == AssistantState.idle) {
      await provider.startRecording();
    } else if (provider.state == AssistantState.speaking) {
      await provider.stopSpeaking();
    }
  }

  void _onPressEnd(VoiceAssistantProvider provider) async {
    if (provider.state == AssistantState.listening && provider.isRecording) {
      await provider.stopRecording();
    }
  }

  IconData _getIconForState(AssistantState state) {
    switch (state) {
      case AssistantState.listening:
        return Icons.mic;
      case AssistantState.thinking:
        return Icons.psychology;
      case AssistantState.speaking:
        return Icons.volume_up;
      case AssistantState.error:
        return Icons.error_outline;
      default:
        return Icons.mic_none_outlined;
    }
  }

  String _getTextForState(AssistantState state) {
    switch (state) {
      case AssistantState.listening:
        return 'Relâchez...';
      case AssistantState.thinking:
        return 'Réflexion...';
      case AssistantState.speaking:
        return 'Répond...';
      case AssistantState.error:
        return 'Erreur';
      default:
        return 'Appuyez';
    }
  }

  Color _getColorForState(AssistantState state) {
    switch (state) {
      case AssistantState.listening:
        return Colors.red;
      case AssistantState.thinking:
        return Colors.orange;
      case AssistantState.speaking:
        return Colors.blue;
      case AssistantState.error:
        return Colors.grey;
      default:
        return const Color(0xFF6B7FD7);
    }
  }

  Gradient _getGradientForState(AssistantState state) {
    Color primaryColor = _getColorForState(state);
    return RadialGradient(
      colors: [
        primaryColor.withOpacity(0.8),
        primaryColor,
      ],
    );
  }
}