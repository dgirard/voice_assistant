import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class TtsEngineSelector extends StatefulWidget {
  final TtsEngine currentEngine;
  final Function(TtsEngine) onEngineChanged;

  const TtsEngineSelector({
    Key? key,
    required this.currentEngine,
    required this.onEngineChanged,
  }) : super(key: key);

  @override
  State<TtsEngineSelector> createState() => _TtsEngineSelectorState();
}

class _TtsEngineSelectorState extends State<TtsEngineSelector> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Moteur de synthèse vocale',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Option Android TTS
            _buildEngineOption(
              engine: TtsEngine.android,
              title: 'Android TTS (Recommandé)',
              subtitle: 'Moteur natif Android, rapide et fiable',
              icon: Icons.android,
              pros: [
                '✓ Pas de coût supplémentaire',
                '✓ Latence très faible',
                '✓ Fonctionne hors ligne',
                '✓ Intégration système optimisée',
              ],
              cons: [
                '• Qualité vocale standard',
                '• Voix moins naturelles',
              ],
            ),
            
            const Divider(height: 32),
            
            // Option Gemini TTS
            _buildEngineOption(
              engine: TtsEngine.gemini,
              title: 'Gemini AI TTS (En développement)',
              subtitle: 'Voix IA très naturelle - Fallback automatique vers Android TTS',
              icon: Icons.auto_awesome,
              pros: [
                '✓ Voix très naturelle et expressive (à venir)',
                '✓ Meilleure prononciation (à venir)',
                '✓ Intonation intelligente (à venir)',
                '✓ Fallback automatique vers Android TTS',
              ],
              cons: [
                '• Actuellement non opérationnel',
                '• Utilise Android TTS en remplacement',
                '• Requiert connexion internet',
                '• Fonctionnalité expérimentale',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineOption({
    required TtsEngine engine,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> pros,
    required List<String> cons,
  }) {
    final isSelected = widget.currentEngine == engine;
    
    return GestureDetector(
      onTap: () => widget.onEngineChanged(engine),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Theme.of(context).primaryColor : null,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                if (engine == TtsEngine.gemini && !isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Text(
                      'BETA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
              ],
            ),
            
            if (isSelected) ...[
              const SizedBox(height: 12),
              
              // Avantages
              Text(
                'Avantages:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 4),
              ...pros.map((pro) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text(
                  pro,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green.shade600,
                  ),
                ),
              )),
              
              const SizedBox(height: 8),
              
              // Inconvénients
              Text(
                'Considérations:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 4),
              ...cons.map((con) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text(
                  con,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange.shade600,
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}