package com.example.voice_assistant

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Enregistrer les plugins TTS Gemini
        flutterEngine.plugins.add(GeminiTtsPlugin())
        flutterEngine.plugins.add(GeminiTtsTestPlugin())
    }
}
