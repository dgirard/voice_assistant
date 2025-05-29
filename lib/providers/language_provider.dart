import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/language_config.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('fr', 'FR');
  LanguageConfig _config = LanguageConfig.french();
  bool _isLanguageLoaded = false;

  // Locales supportés
  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'), // Français
    Locale('en', 'US'), // Anglais
    Locale('ja', 'JP'), // Japonais
    Locale('es', 'ES'), // Espagnol
    Locale('it', 'IT'), // Italien
    Locale('de', 'DE'), // Allemand
    Locale('zh', 'CN'), // Chinois
  ];

  Locale get currentLocale => _currentLocale;
  LanguageConfig get config => _config;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageTag = prefs.getString('language');
      
      if (savedLanguageTag != null) {
        final locale = _parseLocale(savedLanguageTag);
        if (supportedLocales.contains(locale)) {
          _currentLocale = locale;
          _config = LanguageConfig.fromLocale(locale);
          print('Langue restaurée depuis les préférences: $savedLanguageTag');
          notifyListeners();
        }
      }
    } catch (e) {
      print('Erreur chargement langue sauvegardée: $e');
    } finally {
      _isLanguageLoaded = true;
    }
  }

  Locale _parseLocale(String languageTag) {
    final parts = languageTag.split('-');
    if (parts.length >= 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  Future<void> changeLanguage(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      print('Locale non supporté: $locale');
      return;
    }

    _currentLocale = locale;
    _config = LanguageConfig.fromLocale(locale);

    // Persistence
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', locale.toLanguageTag());
    } catch (e) {
      print('Erreur sauvegarde langue: $e');
    }

    notifyListeners();
  }

  String getLanguageName(Locale locale, BuildContext context) {
    switch (locale.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      case 'es':
        return 'Español';
      case 'it':
        return 'Italiano';
      case 'de':
        return 'Deutsch';
      case 'zh':
        return '中文';
      default:
        return locale.languageCode;
    }
  }

  String getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return '🇫🇷';
      case 'en':
        return '🇬🇧';
      case 'ja':
        return '🇯🇵';
      case 'es':
        return '🇪🇸';
      case 'it':
        return '🇮🇹';
      case 'de':
        return '🇩🇪';
      case 'zh':
        return '🇨🇳';
      default:
        return '🌐';
    }
  }

  /// S'assurer que la langue est complètement chargée depuis les préférences
  Future<void> ensureLanguageLoaded() async {
    if (!_isLanguageLoaded) {
      // Attendre que le chargement initial soit terminé
      int attempts = 0;
      while (!_isLanguageLoaded && attempts < 50) { // Max 5 secondes
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
    }
  }
}