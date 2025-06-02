import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)?.initializingAssistant ?? 'Initializing voice assistant...'),
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
                      _getStateText(context, provider.state),
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

  String _getStateText(BuildContext context, AssistantState state) {
    final localizations = AppLocalizations.of(context);
    switch (state) {
      case AssistantState.idle:
        return localizations?.ready ?? 'Ready to listen';
      case AssistantState.listening:
        return localizations?.listening ?? 'I\'m listening...';
      case AssistantState.readyToSend:
        return localizations?.readyToSend ?? 'Message ready to send';
      case AssistantState.thinking:
        return localizations?.thinking ?? 'Thinking...';
      case AssistantState.speaking:
        return localizations?.speaking ?? 'Speaking...';
      case AssistantState.error:
        return localizations?.connectionError ?? 'Connection error';
    }
  }

  Color _getStateColor(AssistantState state) {
    switch (state) {
      case AssistantState.idle:
        return Colors.green;
      case AssistantState.listening:
        return Colors.red;
      case AssistantState.readyToSend:
        return Colors.green;
      case AssistantState.thinking:
        return Colors.orange;
      case AssistantState.speaking:
        return Colors.blue;
      case AssistantState.error:
        return Colors.grey;
    }
  }
}