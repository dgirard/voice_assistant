import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/voice_assistant_provider.dart';
import 'providers/language_provider.dart';
import 'screens/voice_screen.dart';
import 'screens/assistant_selection_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/gemini_tts_test_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'config/env_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Charger les variables d'environnement
    await dotenv.load(fileName: ".env");
    
    // Valider la configuration
    EnvConfig.validateEnvironment();
    
    runApp(const VoiceAssistantApp());
  } catch (e) {
    print('Erreur d\'initialisation: $e');
    runApp(const ErrorApp());
  }
}

class VoiceAssistantApp extends StatelessWidget {
  const VoiceAssistantApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => VoiceAssistantProvider()),
      ],
      child: Consumer2<LanguageProvider, VoiceAssistantProvider>(
        builder: (context, languageProvider, voiceProvider, child) {
          // Connecter le LanguageProvider au VoiceAssistantProvider
          voiceProvider.setLanguageProvider(languageProvider);
          
          return MaterialApp(
            title: 'Voice Assistant',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.grey[50],
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                elevation: 0,
                centerTitle: true,
              ),
            ),
            // Internationalization configuration
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LanguageProvider.supportedLocales,
            locale: languageProvider.currentLocale,
            home: const VoiceScreen(),
            routes: {
              '/assistant-selection': (context) => const AssistantSelectionScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/gemini-tts-test': (context) => const GeminiTtsTestScreen(),
              '/qr-scanner': (context) => const QrScannerScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Configuration Error',
      home: Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                SizedBox(height: 24),
                Text(
                  'Configuration Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Missing API key. Please check the console for instructions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}