import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';

class VoiceButton extends StatefulWidget {
  const VoiceButton({Key? key}) : super(key: key);

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
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
        switch (provider.state) {
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

        return GestureDetector(
          onTapDown: (_) => _onPressStart(provider),
          onTapUp: (_) => _onPressEnd(provider),
          onTapCancel: () => _onPressEnd(provider),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _getGradientForState(provider.state),
                  boxShadow: [
                    BoxShadow(
                      color: _getColorForState(provider.state).withOpacity(0.3),
                      blurRadius: 20 * _pulseAnimation.value,
                      spreadRadius: 5 * _pulseAnimation.value,
                    ),
                  ],
                ),
                transform: Matrix4.identity()
                  ..scale(_scaleAnimation.value),
                child: Icon(
                  _getIconForState(provider.state),
                  size: 50,
                  color: Colors.white,
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _onPressStart(VoiceAssistantProvider provider) async {
    if (provider.state == AssistantState.idle) {
      await provider.startListening();
    } else if (provider.state == AssistantState.speaking) {
      await provider.stopSpeaking();
    }
  }

  void _onPressEnd(VoiceAssistantProvider provider) async {
    if (provider.state == AssistantState.listening) {
      await provider.stopListening();
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
        return Icons.error;
      default:
        return Icons.mic_none;
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
        return Colors.blue;
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