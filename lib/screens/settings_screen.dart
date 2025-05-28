import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';
import '../services/tts_service.dart';
import '../widgets/tts_engine_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.settings,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Configuration',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Personnalisez votre expérience d\'assistant vocal',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // TTS Engine Selector
            Consumer<VoiceAssistantProvider>(
              builder: (context, provider, child) {
                return TtsEngineSelector(
                  currentEngine: provider.currentTtsEngine,
                  onEngineChanged: (engine) {
                    provider.setTtsEngine(engine);
                    
                    // Afficher un message de confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          engine == TtsEngine.android 
                            ? 'Moteur Android TTS activé' 
                            : 'Moteur Gemini AI activé',
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              },
            ),
            
            // Test TTS Section
            _buildTestSection(context),
            
            // Gemini TTS Test Section
            _buildGeminiTestSection(context),
            
            // Information Section
            _buildInfoSection(context),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Test de synthèse vocale',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Testez la qualité de la voix du moteur sélectionné.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Consumer<VoiceAssistantProvider>(
              builder: (context, provider, child) {
                return ElevatedButton.icon(
                  onPressed: provider.state == AssistantState.speaking
                      ? null
                      : () => _testTts(context, provider),
                  icon: provider.state == AssistantState.speaking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.volume_up),
                  label: Text(
                    provider.state == AssistantState.speaking
                        ? 'Test en cours...'
                        : 'Tester la voix',
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    onPrimary: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeminiTestSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Test avancé Gemini TTS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Testez directement l\'API Gemini TTS avec des paramètres avancés.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/gemini-tts-test');
              },
              icon: const Icon(Icons.science),
              label: const Text('Ouvrir le laboratoire TTS'),
              style: ElevatedButton.styleFrom(
                primary: Colors.purple,
                onPrimary: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'À propos des moteurs TTS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoItem(
              'Android TTS',
              'Moteur intégré au système Android, rapide et fiable.',
              Icons.android,
              Colors.green,
            ),
            
            const Divider(height: 24),
            
            _buildInfoItem(
              'Gemini AI TTS',
              'IA générative avec voix plus naturelle et expressive.',
              Icons.auto_awesome,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String description, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _testTts(BuildContext context, VoiceAssistantProvider provider) async {
    String testMessage;
    
    // Message différent selon le moteur pour bien distinguer
    if (provider.currentTtsEngine == TtsEngine.android) {
      testMessage = 'Bonjour ! Vous entendez actuellement la voix Android TTS standard. Cette voix est rapide et fiable.';
    } else {
      testMessage = 'Bonjour ! Vous devriez entendre la voix Gemini AI, plus naturelle et expressive.';
    }
    
    try {
      await provider.stopSpeaking(); // Arrêter toute synthèse en cours
      await provider.testTtsEngine(testMessage);
    } catch (e) {
      // Afficher un message informatif pour Gemini TTS
      String errorMessage;
      if (provider.currentTtsEngine == TtsEngine.gemini) {
        errorMessage = 'Gemini TTS n\'est pas encore opérationnel. L\'app utilise Android TTS en remplacement.';
      } else {
        errorMessage = 'Erreur lors du test: $e';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: provider.currentTtsEngine == TtsEngine.gemini 
              ? Colors.orange 
              : Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}