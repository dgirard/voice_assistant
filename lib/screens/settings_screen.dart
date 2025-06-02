import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';
import '../services/tts_service.dart';
import '../widgets/tts_engine_selector.dart';
import '../widgets/language_selector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.settings ?? 'Paramètres'),
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
                  Text(
                    AppLocalizations.of(context)?.settings ?? 'Configuration',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.settingsDescription ?? 'Customize your voice assistant experience',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Language Selector
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: LanguageSelector(),
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
                            ? AppLocalizations.of(context)?.androidTtsActivated ?? 'Android TTS engine activated'
                            : AppLocalizations.of(context)?.geminiAiActivated ?? 'Gemini AI engine activated',
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
                Text(
                  AppLocalizations.of(context)?.ttsTestTitle ?? 'Text-to-speech test',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.ttsTestDescription ?? 'Test the quality of the selected engine\'s voice.',
              style: const TextStyle(color: Colors.grey),
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
                        ? AppLocalizations.of(context)?.testInProgress ?? 'Test in progress...'
                        : AppLocalizations.of(context)?.testVoice ?? 'Test Voice',
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
                Text(
                  AppLocalizations.of(context)?.advancedGeminiTtsTest ?? 'Advanced Gemini TTS test',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.advancedGeminiTtsDescription ?? 'Test the Gemini TTS API directly with advanced parameters.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/gemini-tts-test');
              },
              icon: const Icon(Icons.science),
              label: Text(AppLocalizations.of(context)?.openTtsLab ?? 'Open TTS Lab'),
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
                Text(
                  AppLocalizations.of(context)?.aboutTtsEngines ?? 'About TTS engines',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoItem(
              context,
              AppLocalizations.of(context)?.androidTts ?? 'Android TTS',
              AppLocalizations.of(context)?.androidTtsSubtitle ?? 'Android\'s built-in engine, fast and reliable.',
              Icons.android,
              Colors.green,
            ),
            
            const Divider(height: 24),
            
            _buildInfoItem(
              context,
              AppLocalizations.of(context)?.geminiTts ?? 'Gemini AI TTS',
              AppLocalizations.of(context)?.geminiAiTtsSubtitle ?? 'Generative AI with more natural and expressive voice.',
              Icons.auto_awesome,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String title, String description, IconData icon, Color color) {
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
      testMessage = AppLocalizations.of(context)?.androidTtsTestMessage ?? 'Hello! You are currently hearing the standard Android TTS voice. This voice is fast and reliable.';
    } else {
      testMessage = AppLocalizations.of(context)?.geminiTtsTestMessage ?? 'Hello! You should hear the Gemini AI voice, more natural and expressive.';
    }
    
    try {
      await provider.stopSpeaking(); // Arrêter toute synthèse en cours
      await provider.testTtsEngine(testMessage);
    } catch (e) {
      // Afficher un message informatif pour Gemini TTS
      String errorMessage;
      if (provider.currentTtsEngine == TtsEngine.gemini) {
        errorMessage = AppLocalizations.of(context)?.geminiTtsNotOperational ?? 'Gemini TTS is not yet operational. The app uses Android TTS as replacement.';
      } else {
        errorMessage = (AppLocalizations.of(context)?.testError ?? 'Error during test: {error}').replaceAll('{error}', e.toString());
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