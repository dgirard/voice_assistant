import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/wave_animation.dart';
import '../widgets/control_bar.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({Key? key}) : super(key: key);

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  bool _isPaused = false;
  bool _isCameraOn = false;
  double _currentAmplitude = 0.0;

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
      appBar: const CustomAppBar(),
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
              
              // Animation des vagues
              Positioned(
                bottom: 150, // Au-dessus de la barre de contrôle
                left: 0,
                right: 0,
                child: WaveAnimation(
                  amplitude: amplitude,
                  isActive: isActive,
                ),
              ),
              
              // Barre de contrôle inférieure
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ControlBar(
                  isPaused: _isPaused,
                  isCameraOn: _isCameraOn,
                  onCameraPressed: _toggleCamera,
                  onSharePressed: _shareAction,
                  onPausePressed: _togglePause,
                  onClosePressed: () => Navigator.of(context).pop(),
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
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
  }
  
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    final provider = context.read<VoiceAssistantProvider>();
    if (_isPaused) {
      if (provider.state == AssistantState.listening) {
        provider.stopListening();
      } else if (provider.state == AssistantState.speaking) {
        provider.stopSpeaking();
      }
    } else {
      if (provider.state == AssistantState.idle) {
        provider.startListening();
      }
    }
  }
  
  void _shareAction() {
    // Implémentation du partage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonction de partage'),
        backgroundColor: Color(0xFF333333),
      ),
    );
  }
}