
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations returned
/// by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Assistant'**
  String get appTitle;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready to listen'**
  String get ready;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'I\'m listening...'**
  String get listening;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// No description provided for @speaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking...'**
  String get speaking;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @testVoice.
  ///
  /// In en, this message translates to:
  /// **'Test Voice'**
  String get testVoice;

  /// No description provided for @newConversation.
  ///
  /// In en, this message translates to:
  /// **'New conversation started'**
  String get newConversation;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// No description provided for @pressToStart.
  ///
  /// In en, this message translates to:
  /// **'Press the microphone button to start'**
  String get pressToStart;

  /// No description provided for @voiceAssistant.
  ///
  /// In en, this message translates to:
  /// **'Voice Assistant'**
  String get voiceAssistant;

  /// No description provided for @selectAssistant.
  ///
  /// In en, this message translates to:
  /// **'Select Assistant'**
  String get selectAssistant;

  /// No description provided for @generalAssistant.
  ///
  /// In en, this message translates to:
  /// **'General Assistant'**
  String get generalAssistant;

  /// No description provided for @specializedAssistants.
  ///
  /// In en, this message translates to:
  /// **'Specialized Assistants'**
  String get specializedAssistants;

  /// No description provided for @ttsEngine.
  ///
  /// In en, this message translates to:
  /// **'TTS Engine'**
  String get ttsEngine;

  /// No description provided for @androidTts.
  ///
  /// In en, this message translates to:
  /// **'Android TTS'**
  String get androidTts;

  /// No description provided for @geminiTts.
  ///
  /// In en, this message translates to:
  /// **'Gemini AI TTS'**
  String get geminiTts;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @communicationError.
  ///
  /// In en, this message translates to:
  /// **'Communication error with assistant'**
  String get communicationError;

  /// No description provided for @loadingAssistants.
  ///
  /// In en, this message translates to:
  /// **'Loading assistants...'**
  String get loadingAssistants;

  /// No description provided for @noAssistants.
  ///
  /// In en, this message translates to:
  /// **'No assistants available'**
  String get noAssistants;

  /// No description provided for @geminiError.
  ///
  /// In en, this message translates to:
  /// **'Error with Gemini'**
  String get geminiError;

  /// No description provided for @raiseError.
  ///
  /// In en, this message translates to:
  /// **'Error with Raise'**
  String get raiseError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @configurationError.
  ///
  /// In en, this message translates to:
  /// **'Configuration error'**
  String get configurationError;

  /// No description provided for @testCompleted.
  ///
  /// In en, this message translates to:
  /// **'Test completed'**
  String get testCompleted;

  /// No description provided for @testFailed.
  ///
  /// In en, this message translates to:
  /// **'Test failed'**
  String get testFailed;

  /// No description provided for @initializingAssistant.
  ///
  /// In en, this message translates to:
  /// **'Initializing voice assistant...'**
  String get initializingAssistant;

  /// No description provided for @readyToSend.
  ///
  /// In en, this message translates to:
  /// **'Message ready to send'**
  String get readyToSend;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// No description provided for @applicationReset.
  ///
  /// In en, this message translates to:
  /// **'Application reset'**
  String get applicationReset;

  /// No description provided for @configuration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// No description provided for @customizeExperience.
  ///
  /// In en, this message translates to:
  /// **'Customize your voice assistant experience'**
  String get customizeExperience;

  /// No description provided for @androidTtsActivated.
  ///
  /// In en, this message translates to:
  /// **'Android TTS engine activated'**
  String get androidTtsActivated;

  /// No description provided for @geminiTtsActivated.
  ///
  /// In en, this message translates to:
  /// **'Gemini AI engine activated'**
  String get geminiTtsActivated;

  /// No description provided for @ttsTest.
  ///
  /// In en, this message translates to:
  /// **'Text-to-speech test'**
  String get ttsTest;

  /// No description provided for @testVoiceQuality.
  ///
  /// In en, this message translates to:
  /// **'Test the quality of the selected engine\'s voice.'**
  String get testVoiceQuality;

  /// No description provided for @testInProgress.
  ///
  /// In en, this message translates to:
  /// **'Test in progress...'**
  String get testInProgress;

  /// No description provided for @advancedGeminiTest.
  ///
  /// In en, this message translates to:
  /// **'Advanced Gemini TTS test'**
  String get advancedGeminiTest;

  /// No description provided for @testGeminiApiDirectly.
  ///
  /// In en, this message translates to:
  /// **'Test the Gemini TTS API directly with advanced parameters.'**
  String get testGeminiApiDirectly;

  /// No description provided for @openTtsLab.
  ///
  /// In en, this message translates to:
  /// **'Open TTS Lab'**
  String get openTtsLab;

  /// No description provided for @aboutTtsEngines.
  ///
  /// In en, this message translates to:
  /// **'About TTS engines'**
  String get aboutTtsEngines;

  /// No description provided for @androidTtsDescription.
  ///
  /// In en, this message translates to:
  /// **'Android\'s built-in engine, fast and reliable.'**
  String get androidTtsDescription;

  /// No description provided for @geminiTtsDescription.
  ///
  /// In en, this message translates to:
  /// **'Generative AI with more natural and expressive voice.'**
  String get geminiTtsDescription;

  /// No description provided for @androidTtsTestMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello! You are currently hearing the standard Android TTS voice. This voice is fast and reliable.'**
  String get androidTtsTestMessage;

  /// No description provided for @geminiTtsTestMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello! You should hear the Gemini AI voice, more natural and expressive.'**
  String get geminiTtsTestMessage;

  /// No description provided for @geminiTtsNotOperational.
  ///
  /// In en, this message translates to:
  /// **'Gemini TTS is not yet operational. The app uses Android TTS as replacement.'**
  String get geminiTtsNotOperational;

  /// No description provided for @testError.
  ///
  /// In en, this message translates to:
  /// **'Error during test: {error}'**
  String get testError;

  /// No description provided for @testGeminiTts.
  ///
  /// In en, this message translates to:
  /// **'Test Gemini TTS'**
  String get testGeminiTts;

  /// No description provided for @testTtsWithGemini.
  ///
  /// In en, this message translates to:
  /// **'Test text-to-speech with Gemini AI'**
  String get testTtsWithGemini;

  /// No description provided for @testConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Test configuration'**
  String get testConfiguration;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice:'**
  String get voice;

  /// No description provided for @koreRecommended.
  ///
  /// In en, this message translates to:
  /// **'Kore (Recommended)'**
  String get koreRecommended;

  /// No description provided for @charonVoice.
  ///
  /// In en, this message translates to:
  /// **'Charon'**
  String get charonVoice;

  /// No description provided for @fenrirVoice.
  ///
  /// In en, this message translates to:
  /// **'Fenrir'**
  String get fenrirVoice;

  /// No description provided for @textToSynthesize.
  ///
  /// In en, this message translates to:
  /// **'Text to synthesize:'**
  String get textToSynthesize;

  /// No description provided for @enterTextToSynthesize.
  ///
  /// In en, this message translates to:
  /// **'Enter text to synthesize...'**
  String get enterTextToSynthesize;

  /// No description provided for @defaultTestText.
  ///
  /// In en, this message translates to:
  /// **'Hello! This is a test of Gemini AI text-to-speech. Does the voice sound natural and expressive?'**
  String get defaultTestText;

  /// No description provided for @runFullTest.
  ///
  /// In en, this message translates to:
  /// **'Run full test'**
  String get runFullTest;

  /// No description provided for @apiConnectivityTest.
  ///
  /// In en, this message translates to:
  /// **'API connectivity test'**
  String get apiConnectivityTest;

  /// No description provided for @testResult.
  ///
  /// In en, this message translates to:
  /// **'Test result'**
  String get testResult;

  /// No description provided for @technicalInfo.
  ///
  /// In en, this message translates to:
  /// **'Technical information'**
  String get technicalInfo;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @audioFormat.
  ///
  /// In en, this message translates to:
  /// **'Audio format'**
  String get audioFormat;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @endpoint.
  ///
  /// In en, this message translates to:
  /// **'Endpoint'**
  String get endpoint;

  /// No description provided for @cleanTempFiles.
  ///
  /// In en, this message translates to:
  /// **'Clean temporary files'**
  String get cleanTempFiles;

  /// No description provided for @geminiTestSuccess.
  ///
  /// In en, this message translates to:
  /// **'🎉 Gemini TTS test successful!'**
  String get geminiTestSuccess;

  /// No description provided for @audioGeneratedLimitedPlayback.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Audio generated, limited playback (experimental version)'**
  String get audioGeneratedLimitedPlayback;

  /// No description provided for @tempFilesDeleted.
  ///
  /// In en, this message translates to:
  /// **'🧹 Temporary files deleted'**
  String get tempFilesDeleted;

  /// No description provided for @cleanupError.
  ///
  /// In en, this message translates to:
  /// **'Error during cleanup: {error}'**
  String get cleanupError;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get general;

  /// No description provided for @specialized.
  ///
  /// In en, this message translates to:
  /// **'SPECIALIZED'**
  String get specialized;

  /// No description provided for @youSay.
  ///
  /// In en, this message translates to:
  /// **'You say:'**
  String get youSay;

  /// No description provided for @assistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant:'**
  String get assistant;

  /// No description provided for @assistantThinking.
  ///
  /// In en, this message translates to:
  /// **'The assistant is thinking'**
  String get assistantThinking;

  /// No description provided for @holdButtonToRecord.
  ///
  /// In en, this message translates to:
  /// **'Hold the button to record your message'**
  String get holdButtonToRecord;

  /// No description provided for @editYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit your message'**
  String get editYourMessage;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @androidTtsRecommended.
  ///
  /// In en, this message translates to:
  /// **'Android TTS (Recommended)'**
  String get androidTtsRecommended;

  /// No description provided for @geminiTtsInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Gemini AI TTS (In development)'**
  String get geminiTtsInDevelopment;

  /// No description provided for @beta.
  ///
  /// In en, this message translates to:
  /// **'BETA'**
  String get beta;

  /// No description provided for @advantages.
  ///
  /// In en, this message translates to:
  /// **'Advantages:'**
  String get advantages;

  /// No description provided for @considerations.
  ///
  /// In en, this message translates to:
  /// **'Considerations:'**
  String get considerations;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @missingApiKey.
  ///
  /// In en, this message translates to:
  /// **'Missing API key. Please check the console for instructions.'**
  String get missingApiKey;

  /// No description provided for @raiseAssistantError.
  ///
  /// In en, this message translates to:
  /// **'Error communicating with the Raise assistant.'**
  String get raiseAssistantError;

  /// No description provided for @couldNotGenerateResponse.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I couldn\'t generate a response.'**
  String get couldNotGenerateResponse;

  /// No description provided for @aiCommunicationError.
  ///
  /// In en, this message translates to:
  /// **'Error communicating with AI.'**
  String get aiCommunicationError;

  /// No description provided for @requestCancelledByUser.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled by user.'**
  String get requestCancelledByUser;

  /// No description provided for @responseGenerationError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while generating the response.'**
  String get responseGenerationError;

  /// No description provided for @geminiTtsErrorFallback.
  ///
  /// In en, this message translates to:
  /// **'Gemini TTS encountered an error. Here is the standard Android voice.'**
  String get geminiTtsErrorFallback;

  /// No description provided for @speak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get speak;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @settingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Customize your voice assistant experience'**
  String get settingsDescription;

  /// No description provided for @geminiAiActivated.
  ///
  /// In en, this message translates to:
  /// **'Gemini AI engine activated'**
  String get geminiAiActivated;

  /// No description provided for @ttsTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Text-to-speech test'**
  String get ttsTestTitle;

  /// No description provided for @ttsTestDescription.
  ///
  /// In en, this message translates to:
  /// **'Test the quality of the selected engine\'s voice.'**
  String get ttsTestDescription;

  /// No description provided for @advancedGeminiTtsTest.
  ///
  /// In en, this message translates to:
  /// **'Advanced Gemini TTS test'**
  String get advancedGeminiTtsTest;

  /// No description provided for @advancedGeminiTtsDescription.
  ///
  /// In en, this message translates to:
  /// **'Test the Gemini TTS API directly with advanced parameters.'**
  String get advancedGeminiTtsDescription;

  /// No description provided for @androidTtsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Android\'s built-in engine, fast and reliable.'**
  String get androidTtsSubtitle;

  /// No description provided for @geminiAiTtsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generative AI with more natural and expressive voice.'**
  String get geminiAiTtsSubtitle;

  /// No description provided for @chooseAssistant.
  ///
  /// In en, this message translates to:
  /// **'Choose assistant'**
  String get chooseAssistant;

  /// No description provided for @geminiTtsDefaultTestText.
  ///
  /// In en, this message translates to:
  /// **'Hello! This is a test of Gemini AI text-to-speech. Does the voice sound natural and expressive?'**
  String get geminiTtsDefaultTestText;

  /// No description provided for @testGeminiTtsDescription.
  ///
  /// In en, this message translates to:
  /// **'Test text-to-speech with Gemini AI'**
  String get testGeminiTtsDescription;

  /// No description provided for @launchFullTest.
  ///
  /// In en, this message translates to:
  /// **'Launch full test'**
  String get launchFullTest;

  /// No description provided for @testSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'✅ Test successful! Audio generated successfully.'**
  String get testSuccessMessage;

  /// No description provided for @audioGeneratedButPlaybackFailed.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Audio generated but playback failed. This is normal - Gemini TTS is experimental.'**
  String get audioGeneratedButPlaybackFailed;

  /// No description provided for @geminiTtsTestSuccess.
  ///
  /// In en, this message translates to:
  /// **'🎉 Gemini TTS test successful!'**
  String get geminiTtsTestSuccess;

  /// No description provided for @testPartiallySuccessful.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Test partially successful'**
  String get testPartiallySuccessful;

  /// No description provided for @connectivityError.
  ///
  /// In en, this message translates to:
  /// **'❌ Connectivity error'**
  String get connectivityError;

  /// No description provided for @geminiAiTtsInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Gemini AI TTS (In development)'**
  String get geminiAiTtsInDevelopment;

  /// No description provided for @geminiAiTtsSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Very natural AI voice - Automatic fallback to Android TTS'**
  String get geminiAiTtsSubtitle2;

  /// No description provided for @androidTtsPros1.
  ///
  /// In en, this message translates to:
  /// **'✓ No additional cost'**
  String get androidTtsPros1;

  /// No description provided for @androidTtsPros2.
  ///
  /// In en, this message translates to:
  /// **'✓ Very low latency'**
  String get androidTtsPros2;

  /// No description provided for @androidTtsPros3.
  ///
  /// In en, this message translates to:
  /// **'✓ Works offline'**
  String get androidTtsPros3;

  /// No description provided for @androidTtsPros4.
  ///
  /// In en, this message translates to:
  /// **'✓ Optimized system integration'**
  String get androidTtsPros4;

  /// No description provided for @androidTtsCons1.
  ///
  /// In en, this message translates to:
  /// **'• Standard voice quality'**
  String get androidTtsCons1;

  /// No description provided for @androidTtsCons2.
  ///
  /// In en, this message translates to:
  /// **'• Less natural voices'**
  String get androidTtsCons2;

  /// No description provided for @geminiAiTtsPros1.
  ///
  /// In en, this message translates to:
  /// **'✓ Very natural voice'**
  String get geminiAiTtsPros1;

  /// No description provided for @geminiAiTtsPros2.
  ///
  /// In en, this message translates to:
  /// **'✓ Expressive intonation'**
  String get geminiAiTtsPros2;

  /// No description provided for @geminiAiTtsPros3.
  ///
  /// In en, this message translates to:
  /// **'✓ Multiple voice styles'**
  String get geminiAiTtsPros3;

  /// No description provided for @geminiAiTtsPros4.
  ///
  /// In en, this message translates to:
  /// **'✓ Generative AI technology'**
  String get geminiAiTtsPros4;

  /// No description provided for @geminiAiTtsCons1.
  ///
  /// In en, this message translates to:
  /// **'• Uses Gemini API quota'**
  String get geminiAiTtsCons1;

  /// No description provided for @geminiAiTtsCons2.
  ///
  /// In en, this message translates to:
  /// **'• Requires internet connection'**
  String get geminiAiTtsCons2;

  /// No description provided for @geminiAiTtsCons3.
  ///
  /// In en, this message translates to:
  /// **'• Experimental version'**
  String get geminiAiTtsCons3;

  /// No description provided for @geminiAiTtsCons4.
  ///
  /// In en, this message translates to:
  /// **'• May have latency'**
  String get geminiAiTtsCons4;

  /// No description provided for @pressMicrophoneToStart.
  ///
  /// In en, this message translates to:
  /// **'Press the microphone button to start a conversation'**
  String get pressMicrophoneToStart;

  /// No description provided for @frenchDescription.
  ///
  /// In en, this message translates to:
  /// **'French - Voice recognition and responses in French'**
  String get frenchDescription;

  /// No description provided for @noResponseGenerated.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I couldn\'t generate a response.'**
  String get noResponseGenerated;

  /// No description provided for @requestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled by user.'**
  String get requestCancelled;

  /// No description provided for @frenchSystemResponse.
  ///
  /// In en, this message translates to:
  /// **'Understood! I am your voice assistant. I will respond naturally and conversationally in English. How can I help you?'**
  String get frenchSystemResponse;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
