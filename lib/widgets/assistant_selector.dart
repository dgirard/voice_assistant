import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';
import '../models/assistant.dart';

class AssistantSelector extends StatelessWidget {
  const AssistantSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceAssistantProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingAssistants) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
          );
        }

        if (provider.availableAssistants.isEmpty) {
          return Container();
        }

        return PopupMenuButton<Assistant>(
          icon: Container(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  provider.selectedAssistant.type == AssistantType.gemini
                      ? Icons.psychology
                      : Icons.smart_toy,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    provider.selectedAssistant.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white70,
                  size: 12,
                ),
              ],
            ),
          ),
          onSelected: (Assistant assistant) {
            provider.selectAssistant(assistant);
          },
          itemBuilder: (BuildContext context) {
            return provider.availableAssistants.map((Assistant assistant) {
              final isSelected = assistant == provider.selectedAssistant;
              
              return PopupMenuItem<Assistant>(
                value: assistant,
                child: Row(
                  children: [
                    Icon(
                      assistant.type == AssistantType.gemini
                          ? Icons.psychology
                          : Icons.smart_toy,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            assistant.displayName,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Theme.of(context).primaryColor : null,
                            ),
                          ),
                          if (assistant.description != null)
                            Text(
                              assistant.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        color: Theme.of(context).primaryColor,
                        size: 16,
                      ),
                  ],
                ),
              );
            }).toList();
          },
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}