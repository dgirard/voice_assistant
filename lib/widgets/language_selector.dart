import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  final bool showLabel;
  final bool compact;

  const LanguageSelector({
    Key? key,
    this.showLabel = true,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        if (compact) {
          return _buildCompactSelector(context, languageProvider);
        }
        return _buildFullSelector(context, languageProvider);
      },
    );
  }

  Widget _buildCompactSelector(BuildContext context, LanguageProvider languageProvider) {
    return PopupMenuButton<Locale>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            languageProvider.getLanguageFlag(languageProvider.currentLocale),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
      onSelected: (locale) => languageProvider.changeLanguage(locale),
      itemBuilder: (context) => LanguageProvider.supportedLocales
          .map((locale) => PopupMenuItem(
                value: locale,
                child: Row(
                  children: [
                    Text(
                      languageProvider.getLanguageFlag(locale),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(languageProvider.getLanguageName(locale, context)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildFullSelector(BuildContext context, LanguageProvider languageProvider) {
    final localizations = AppLocalizations.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showLabel) ...[
              Text(
                localizations?.language ?? 'Language',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
            ],
            DropdownButtonFormField<Locale>(
              value: languageProvider.currentLocale,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: LanguageProvider.supportedLocales
                  .map((locale) => DropdownMenuItem(
                        value: locale,
                        child: Row(
                          children: [
                            Text(
                              languageProvider.getLanguageFlag(locale),
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              languageProvider.getLanguageName(locale, context),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (locale) {
                if (locale != null) {
                  languageProvider.changeLanguage(locale);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              _getLanguageDescription(context, languageProvider.currentLocale),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageDescription(BuildContext context, Locale locale) {
    final localizations = AppLocalizations.of(context);
    
    switch (locale.languageCode) {
      case 'fr':
        return localizations?.french ?? 'Français - Reconnaissance vocale et réponses en français';
      case 'en':
        return localizations?.english ?? 'English - Voice recognition and responses in English';
      case 'ja':
        return localizations?.japanese ?? '日本語 - 日本語での音声認識と応答';
      default:
        return '';
    }
  }
}