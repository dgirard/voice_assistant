import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/voice_assistant_provider.dart';
import 'screens/voice_screen.dart';

void main() {
  runApp(const VoiceAssistantApp());
}

class VoiceAssistantApp extends StatelessWidget {
  const VoiceAssistantApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VoiceAssistantProvider(),
      child: MaterialApp(
        title: 'Assistant Vocal',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const VoiceScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}