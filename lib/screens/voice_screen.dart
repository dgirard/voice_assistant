import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';
import '../widgets/wave_animation.dart';
import '../widgets/control_bar.dart';
import '../widgets/speech_text_display.dart';
import '../widgets/voice_record_button.dart';
import '../widgets/language_selector.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({Key? key}) : super(key: key);

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  bool _isCameraOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoiceAssistantProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Consumer<VoiceAssistantProvider>(
        builder: (context, provider, child) {
          // Déterminer l'amplitude basée sur l'état sans setState
          final amplitude = _getAmplitudeForState(provider.state);
          final isActive = _isVoiceActive(provider.state);
          
          return Stack(
            children: [
              // Zone de contenu principale
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF000000),
                      Color(0xFF101015),
                    ],
                  ),
                ),
              ),
              
              // Zone de texte centrale
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                bottom: 300,
                child: const SpeechTextDisplay(),
              ),
              
              // Animation des vagues
              Positioned(
                bottom: 150, // Au-dessus de la barre de contrôle
                left: 0,
                right: 0,
                child: Consumer<VoiceAssistantProvider>(
                  builder: (context, provider, child) {
                    double waveAmplitude;
                    if (provider.state == AssistantState.listening) {
                      // Utiliser le niveau sonore réel pendant l'écoute
                      waveAmplitude = 0.2 + (provider.currentSoundLevel * 0.8);
                    } else {
                      // Utiliser l'amplitude basée sur l'état pour les autres cas
                      waveAmplitude = amplitude;
                    }
                    
                    return WaveAnimation(
                      amplitude: waveAmplitude,
                      isActive: isActive,
                    );
                  },
                ),
              ),
              
              // Bouton d'enregistrement central
              Positioned(
                bottom: 200,
                left: 0,
                right: 0,
                child: const Center(
                  child: VoiceRecordButton(),
                ),
              ),
              
              // Barre de contrôle inférieure
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ControlBar(
                  isPaused: false, // Plus de logique pause/play
                  isCameraOn: false,
                  onCameraPressed: null, // Supprimé - remplacé par QR
                  onPausePressed: null, // Bouton pause supprimé
                  onClosePressed: _startNewConversation,
                ),
              ),
              
              // Indicateur d'état central (optionnel)
              if (!provider.isInitialized)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Initialisation...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              
              
            ],
          );
        },
      ),
    );
  }
  
  double _getAmplitudeForState(AssistantState state) {
    switch (state) {
      case AssistantState.listening:
        return 0.8;
      case AssistantState.thinking:
        return 0.5;
      case AssistantState.speaking:
        return 0.9;
      default:
        return 0.1;
    }
  }
  
  bool _isVoiceActive(AssistantState state) {
    return state == AssistantState.listening ||
           state == AssistantState.thinking ||
           state == AssistantState.speaking;
  }
  
  void _toggleCamera() {
    if (mounted) {
      setState(() {
        _isCameraOn = !_isCameraOn;
      });
    }
  }
  
  // Méthode supprimée - plus de logique pause/play
  
  void _startNewConversation() async {
    final provider = context.read<VoiceAssistantProvider>();
    
    // Reset complet de l'application - comme au démarrage
    await provider.resetToInitialState();
    
    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.refresh, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text(
              'Application réinitialisée',
              style: TextStyle(
                fontFamily: 'Chakra Petch',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6B7FD7),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  
}