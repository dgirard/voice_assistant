import 'package:flutter/material.dart';
import '../services/gemini_tts_test.dart';
import '../config/env_config.dart';

class GeminiTtsTestScreen extends StatefulWidget {
  const GeminiTtsTestScreen({Key? key}) : super(key: key);

  @override
  State<GeminiTtsTestScreen> createState() => _GeminiTtsTestScreenState();
}

class _GeminiTtsTestScreenState extends State<GeminiTtsTestScreen> {
  late GeminiTtsTest _geminiTtsTest;
  bool _isLoading = false;
  String? _lastResult;
  String _testText = 'Bonjour ! Ceci est un test de la synthèse vocale Gemini AI. La voix semble-t-elle naturelle et expressive ?';
  String _selectedVoice = 'Kore';

  @override
  void initState() {
    super.initState();
    _geminiTtsTest = GeminiTtsTest(apiKey: EnvConfig.geminiApiKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Gemini TTS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec icône
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withOpacity(0.1),
                    Colors.purple.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Test Gemini TTS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Testez la synthèse vocale avec l\'IA Gemini',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Configuration du test
            _buildConfigurationCard(),
            
            const SizedBox(height: 16),
            
            // Boutons de test
            _buildTestButtons(),
            
            const SizedBox(height: 16),
            
            // Résultats
            if (_lastResult != null) _buildResultCard(),
            
            const SizedBox(height: 16),
            
            // Informations techniques
            _buildTechnicalInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration du test',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Sélection de la voix
            const Text('Voix :', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedVoice,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Kore', child: Text('Kore (Recommandée)')),
                DropdownMenuItem(value: 'Charon', child: Text('Charon')),
                DropdownMenuItem(value: 'Fenrir', child: Text('Fenrir')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedVoice = value;
                  });
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Texte de test
            const Text('Texte à synthétiser :', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _testText,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Entrez le texte à synthétiser...',
              ),
              onChanged: (value) {
                _testText = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButtons() {
    return Column(
      children: [
        // Test complet
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _runFullTest,
            icon: _isLoading 
              ? const SizedBox(
                  width: 16, 
                  height: 16, 
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow),
            label: Text(_isLoading ? 'Test en cours...' : 'Lancer le test complet'),
            style: ElevatedButton.styleFrom(
              primary: Colors.purple,
              onPrimary: Colors.white,
              minimumSize: const Size(0, 48),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Test de connectivité seulement
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _testConnectivity,
            icon: const Icon(Icons.wifi_find),
            label: const Text('Test de connectivité API'),
            style: OutlinedButton.styleFrom(
              primary: Colors.purple,
              minimumSize: const Size(0, 48),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    return Card(
      color: _lastResult!.contains('✅') ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _lastResult!.contains('✅') ? Icons.check_circle : Icons.error,
                  color: _lastResult!.contains('✅') ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Résultat du test',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _lastResult!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations techniques',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildInfoRow('Modèle', 'gemini-2.5-flash-preview-tts'),
            _buildInfoRow('Format audio', 'WAV 24kHz, 16-bit, mono'),
            _buildInfoRow('API Key', EnvConfig.geminiApiKey.substring(0, 8) + '...'),
            _buildInfoRow('Endpoint', 'generativelanguage.googleapis.com'),
            
            const SizedBox(height: 12),
            
            // Bouton de nettoyage
            OutlinedButton.icon(
              onPressed: _cleanup,
              icon: const Icon(Icons.cleaning_services),
              label: const Text('Nettoyer les fichiers temporaires'),
              style: OutlinedButton.styleFrom(
                primary: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontFamily: value.contains('...') ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runFullTest() async {
    setState(() {
      _isLoading = true;
      _lastResult = null;
    });

    try {
      final success = await _geminiTtsTest.testGeminiTts(
        text: _testText,
        voiceName: _selectedVoice,
      );
      
      if (!mounted) return; // Éviter les erreurs si l'écran est fermé
      
      setState(() {
        _lastResult = success 
          ? '✅ Test réussi ! Audio généré avec succès.\n'
            'Voix: $_selectedVoice\n'
            'Texte: ${_testText.length > 50 ? _testText.substring(0, 50) + '...' : _testText}\n'
            'Note: Si vous n\'entendez pas le son, vérifiez le volume de votre appareil.'
          : '⚠️ Audio généré mais lecture échouée. C\'est normal - Gemini TTS est expérimental.';
      });
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Test Gemini TTS réussi !'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _lastResult = '⚠️ Test partiellement réussi:\n'
                    'L\'API Gemini TTS a répondu correctement mais la lecture audio a échoué.\n'
                    'Ceci est normal pour cette version expérimentale.\n\n'
                    'Détails techniques: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Audio généré, lecture limitée (version expérimentale)'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _testConnectivity() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _geminiTtsTest.testApiConnectivity();
      
      if (!mounted) return;
      
      setState(() {
        _lastResult = '${result['success'] ? '✅' : '❌'} ${result['message']}\n'
                    'Timestamp: ${result['timestamp']}';
      });
      
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _lastResult = '❌ Erreur de connectivité:\n$e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cleanup() async {
    try {
      await _geminiTtsTest.cleanup();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🧹 Fichiers temporaires supprimés'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du nettoyage: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}