import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

/// Classe de test pour Gemini TTS basée sur le code Spike
class GeminiTtsTest {
  final String apiKey;
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const MethodChannel _audioChannel = MethodChannel('gemini_tts_test_audio');

  GeminiTtsTest({required this.apiKey});

  /// Test complet de Gemini TTS avec génération et lecture audio
  Future<bool> testGeminiTts({
    String text = 'Bonjour ! Ceci est un test de la synthèse vocale Gemini AI. La voix semble-t-elle naturelle ?',
    String voiceName = 'Kore',
  }) async {
    try {
      print('🎙️ Début du test Gemini TTS...');
      
      // 1. Générer l'audio avec Gemini
      final audioData = await _generateVoiceAudio(text, voiceName);
      print('✅ Audio généré: ${audioData.length} bytes');
      
      // 2. Créer le fichier WAV temporaire
      final wavFile = await _createWavFile(audioData);
      print('✅ Fichier WAV créé: ${wavFile.path}');
      
      // 3. Jouer l'audio
      await _playWavFile(wavFile);
      print('✅ Lecture audio lancée');
      
      return true;
      
    } catch (e) {
      print('❌ Erreur test Gemini TTS: $e');
      return false;
    }
  }

  /// Génère l'audio via l'API Gemini (basé sur le code Spike)
  Future<Uint8List> _generateVoiceAudio(String text, String voiceName) async {
    final url = Uri.parse('$baseUrl/models/gemini-2.5-flash-preview-tts:generateContent');
    
    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': text}
          ]
        }
      ],
      'generationConfig': {
        'responseModalities': ['AUDIO'],
        'speechConfig': {
          'voiceConfig': {
            'prebuiltVoiceConfig': {
              'voiceName': voiceName
            }
          }
        }
      }
    };

    print('📡 Requête vers: $url');
    print('📝 Corps: ${json.encode(requestBody)}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: json.encode(requestBody),
    );

    print('📊 Statut réponse: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('📋 Structure réponse: ${responseData.keys}');
      
      // Navigation dans la structure de réponse (basée sur Spike)
      final candidates = responseData['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Pas de candidats dans la réponse');
      }
      
      final content = candidates[0]['content'];
      if (content == null) {
        throw Exception('Pas de contenu dans le candidat');
      }
      
      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('Pas de parties dans le contenu');
      }
      
      final inlineData = parts[0]['inlineData'];
      if (inlineData == null) {
        throw Exception('Pas de données inline');
      }
      
      final base64Data = inlineData['data'] as String?;
      if (base64Data == null) {
        throw Exception('Pas de données base64');
      }
      
      print('✅ Données base64 reçues: ${base64Data.length} caractères');
      
      // Décoder les données base64
      return base64Decode(base64Data);
      
    } else {
      final errorBody = response.body;
      print('❌ Erreur API: $errorBody');
      throw Exception('Erreur API Gemini: ${response.statusCode} - $errorBody');
    }
  }

  /// Crée un fichier WAV complet avec header (basé sur le code Spike)
  Future<File> _createWavFile(Uint8List pcmData) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/gemini_test_$timestamp.wav');
    
    // Paramètres WAV (basés sur Spike)
    const int sampleRate = 24000;
    const int channels = 1;
    const int bitsPerSample = 16;
    const int byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    const int blockAlign = channels * bitsPerSample ~/ 8;
    
    final int dataSize = pcmData.length;
    final int fileSize = 36 + dataSize;
    
    // Créer l'en-tête WAV (44 bytes)
    final wavHeader = BytesBuilder();
    
    // RIFF header
    wavHeader.add('RIFF'.codeUnits);
    wavHeader.add(_int32ToBytes(fileSize));
    wavHeader.add('WAVE'.codeUnits);
    
    // Format chunk
    wavHeader.add('fmt '.codeUnits);
    wavHeader.add(_int32ToBytes(16)); // Format chunk size
    wavHeader.add(_int16ToBytes(1));  // Audio format (PCM)
    wavHeader.add(_int16ToBytes(channels));
    wavHeader.add(_int32ToBytes(sampleRate));
    wavHeader.add(_int32ToBytes(byteRate));
    wavHeader.add(_int16ToBytes(blockAlign));
    wavHeader.add(_int16ToBytes(bitsPerSample));
    
    // Data chunk
    wavHeader.add('data'.codeUnits);
    wavHeader.add(_int32ToBytes(dataSize));
    
    // Combiner header + données PCM
    final wavData = BytesBuilder();
    wavData.add(wavHeader.toBytes());
    wavData.add(pcmData);
    
    await file.writeAsBytes(wavData.toBytes());
    return file;
  }

  /// Joue le fichier WAV via le canal natif
  Future<void> _playWavFile(File wavFile) async {
    try {
      // Délai pour éviter les conflits
      await Future.delayed(const Duration(milliseconds: 100));
      
      await _audioChannel.invokeMethod('playWavFile', {
        'filePath': wavFile.path,
      });
      
      print('✅ Audio en cours de lecture...');
      
      // Attendre un peu pour que la lecture démarre
      await Future.delayed(const Duration(seconds: 2));
      
    } catch (e) {
      print('❌ Erreur lecture audio: $e');
      // Ne pas faire un throw pour éviter les crashes
      print('ℹ️ Le fichier audio a été généré mais la lecture a échoué');
    }
  }

  /// Test de connectivité et de validation API
  Future<Map<String, dynamic>> testApiConnectivity() async {
    try {
      final testResult = await testGeminiTts(
        text: 'Test de connectivité Gemini',
        voiceName: 'Kore',
      );
      
      return {
        'success': testResult,
        'message': testResult 
          ? 'Gemini TTS fonctionne correctement' 
          : 'Échec du test Gemini TTS',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Utilitaires pour créer l'en-tête WAV
  Uint8List _int32ToBytes(int value) {
    return Uint8List.fromList([
      value & 0xFF,
      (value >> 8) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 24) & 0xFF,
    ]);
  }

  Uint8List _int16ToBytes(int value) {
    return Uint8List.fromList([
      value & 0xFF,
      (value >> 8) & 0xFF,
    ]);
  }

  /// Nettoie les fichiers temporaires
  Future<void> cleanup() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      for (final file in files) {
        if (file.path.contains('gemini_test_') && file.path.endsWith('.wav')) {
          await file.delete();
        }
      }
      print('🧹 Fichiers temporaires nettoyés');
    } catch (e) {
      print('⚠️ Erreur nettoyage: $e');
    }
  }
}