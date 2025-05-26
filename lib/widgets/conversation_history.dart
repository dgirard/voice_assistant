import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';

class ConversationHistory extends StatelessWidget {
  const ConversationHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceAssistantProvider>(
      builder: (context, provider, child) {
        if (provider.conversationHistory.isEmpty) {
          return const Center(
            child: Text(
              'Appuyez sur le bouton microphone pour commencer une conversation',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(16),
          itemCount: provider.conversationHistory.length,
          itemBuilder: (context, index) {
            final reversedIndex = provider.conversationHistory.length - 1 - index;
            final message = provider.conversationHistory[reversedIndex];
            final isUser = message.startsWith('Vous:');
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser) ...[
                    const Spacer(),
                    const SizedBox(width: 50),
                  ],
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue[100] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUser ? Colors.blue : Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUser ? 'Vous' : 'Assistant',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isUser ? Colors.blue[700] : Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message.substring(message.indexOf(':') + 2),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isUser) ...[
                    const SizedBox(width: 50),
                    const Spacer(),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}