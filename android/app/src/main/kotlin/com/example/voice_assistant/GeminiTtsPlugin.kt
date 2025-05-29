package com.example.voice_assistant

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*

class GeminiTtsPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var audioTrack: AudioTrack? = null
    private var playbackJob: Job? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "gemini_tts_audio")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "playAudio" -> {
                val audioData = call.argument<ByteArray>("audioData")
                if (audioData != null) {
                    playAudio(audioData, result)
                } else {
                    result.error("INVALID_ARGUMENT", "audioData is null", null)
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

    private fun playAudio(audioData: ByteArray, result: Result) {
        try {
            // Arrêter toute lecture en cours
            stopAudio()

            // Configuration audio pour WAV 24kHz, 16-bit, mono (format Gemini)
            val sampleRate = 24000
            val channelConfig = AudioFormat.CHANNEL_OUT_MONO
            val audioFormat = AudioFormat.ENCODING_PCM_16BIT

            val bufferSize = AudioTrack.getMinBufferSize(sampleRate, channelConfig, audioFormat)

            audioTrack = AudioTrack.Builder()
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                        .build()
                )
                .setAudioFormat(
                    AudioFormat.Builder()
                        .setSampleRate(sampleRate)
                        .setEncoding(audioFormat)
                        .setChannelMask(channelConfig)
                        .build()
                )
                .setBufferSizeInBytes(bufferSize)
                .build()

            // Extraire les données PCM du WAV (ignorer l'en-tête WAV de 44 bytes)
            val pcmData = if (audioData.size > 44) {
                audioData.sliceArray(44 until audioData.size)
            } else {
                audioData
            }

            audioTrack?.play()

            // Lecture asynchrone
            playbackJob = CoroutineScope(Dispatchers.IO).launch {
                try {
                    audioTrack?.write(pcmData, 0, pcmData.size)
                    withContext(Dispatchers.Main) {
                        result.success(null)
                    }
                } catch (e: Exception) {
                    withContext(Dispatchers.Main) {
                        result.error("PLAYBACK_ERROR", e.message, null)
                    }
                }
            }

        } catch (e: Exception) {
            result.error("AUDIO_ERROR", e.message, null)
        }
    }

    private fun stopAudio() {
        playbackJob?.cancel()
        audioTrack?.apply {
            if (state == AudioTrack.STATE_INITIALIZED) {
                stop()
                release()
            }
        }
        audioTrack = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopAudio()
        channel.setMethodCallHandler(null)
    }
}