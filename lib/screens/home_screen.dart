import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';
import '../widgets/voice_button.dart';
import '../widgets/conversation_history.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      appBar: AppBar(
        title: const Text(
          'Assistant Vocal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<VoiceAssistantProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: provider.conversationHistory.isNotEmpty
                    ? () => provider.clearHistory()
                    : null,
              );
            },
          ),
        ],
      ),
      body: Consumer<VoiceAssistantProvider>(
        builder: (context, provider, child) {
          if (!provider.isInitialized) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initialisation de l\'assistant vocal...'),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Zone d'état et texte actuel
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _getStateText(provider.state),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getStateColor(provider.state),
                      ),
                    ),
                    if (provider.currentText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        provider.currentText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Historique des conversations
              const Expanded(
                child: ConversationHistory(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: const VoiceButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _getStateText(AssistantState state) {
    switch (state) {
      case AssistantState.idle:
        return 'Prêt à vous écouter';
      case AssistantState.listening:
        return 'Je vous écoute...';
      case AssistantState.thinking:
        return 'Je réfléchis...';
      case AssistantState.speaking:
        return 'Je réponds...';
      case AssistantState.error:
        return 'Erreur de connexion';
    }
  }

  Color _getStateColor(AssistantState state) {
    switch (state) {
      case AssistantState.idle:
        return Colors.green;
      case AssistantState.listening:
        return Colors.red;
      case AssistantState.thinking:
        return Colors.orange;
      case AssistantState.speaking:
        return Colors.blue;
      case AssistantState.error:
        return Colors.grey;
    }
  }
}