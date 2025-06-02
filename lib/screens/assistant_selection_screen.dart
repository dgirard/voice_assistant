import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/voice_assistant_provider.dart';
import '../models/assistant.dart';

class AssistantSelectionScreen extends StatelessWidget {
  const AssistantSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)?.chooseAssistant ?? 'Choose assistant',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Chakra Petch',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<VoiceAssistantProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingAssistants) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)?.loadingAssistants ?? 'Loading assistants...',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
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
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.availableAssistants.length,
              itemBuilder: (context, index) {
                final assistant = provider.availableAssistants[index];
                final isSelected = assistant == provider.selectedAssistant;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        await provider.selectAssistant(assistant);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF6B7FD7).withOpacity(0.2)
                              : const Color(0xFF202025).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(color: const Color(0xFF6B7FD7), width: 2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Icône de l'assistant
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: assistant.type == AssistantType.gemini
                                    ? const Color(0xFF4285F4)
                                    : const Color(0xFF34A853),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                assistant.type == AssistantType.gemini
                                    ? Icons.psychology
                                    : Icons.smart_toy,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Informations de l'assistant
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    assistant.displayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Chakra Petch',
                                    ),
                                  ),
                                  if (assistant.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      assistant.description!,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontFamily: 'Chakra Petch',
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: assistant.type == AssistantType.gemini
                                          ? const Color(0xFF4285F4).withOpacity(0.2)
                                          : const Color(0xFF34A853).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      assistant.type == AssistantType.gemini
                                          ? (AppLocalizations.of(context)?.general ?? 'GENERAL')
                                          : (AppLocalizations.of(context)?.specialized ?? 'SPECIALIZED'),
                                      style: TextStyle(
                                        color: assistant.type == AssistantType.gemini
                                            ? const Color(0xFF4285F4)
                                            : const Color(0xFF34A853),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Chakra Petch',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Indicateur de sélection
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF6B7FD7),
                                size: 24,
                              )
                            else
                              const Icon(
                                Icons.circle_outlined,
                                color: Colors.white30,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}