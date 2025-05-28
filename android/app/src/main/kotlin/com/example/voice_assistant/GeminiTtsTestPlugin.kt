package com.example.voice_assistant

import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.IOException

class GeminiTtsTestPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var mediaPlayer: MediaPlayer? = null
    private val handler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "gemini_tts_test_audio")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "playWavFile" -> {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    playWavFile(filePath, result)
                } else {
                    result.error("INVALID_ARGUMENT", "filePath is null", null)
                }
            }
            "stopAudio" -> {
                stopAudio()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun playWavFile(filePath: String, result: Result) {
        try {
            // Arrêter toute lecture en cours
            stopAudio()

            val file = File(filePath)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "Le fichier audio n'existe pas: $filePath", null)
                return
            }

            var resultSent = false

            mediaPlayer = MediaPlayer().apply {
                setDataSource(filePath)
                
                setOnPreparedListener {
                    start()
                    if (!resultSent) {
                        resultSent = true
                        result.success("Lecture démarrée")
                    }
                }
                
                setOnCompletionListener {
                    // Ne pas renvoyer de résultat ici car déjà envoyé
                    release()
                    mediaPlayer = null
                }
                
                setOnErrorListener { _, what, extra ->
                    if (!resultSent) {
                        resultSent = true
                        result.error("PLAYBACK_ERROR", "Erreur lecture: what=$what, extra=$extra", null)
                    }
                    release()
                    mediaPlayer = null
                    true
                }
                
                prepareAsync()
            }

        } catch (e: IOException) {
            result.error("IO_ERROR", "Erreur I/O: ${e.message}", null)
        } catch (e: Exception) {
            result.error("UNKNOWN_ERROR", "Erreur inconnue: ${e.message}", null)
        }
    }

    private fun stopAudio() {
        mediaPlayer?.let {
            try {
                if (it.isPlaying) {
                    it.stop()
                }
                it.release()
            } catch (e: Exception) {
                // Ignorer les erreurs de nettoyage
            }
            mediaPlayer = null
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopAudio()
        channel.setMethodCallHandler(null)
    }
}