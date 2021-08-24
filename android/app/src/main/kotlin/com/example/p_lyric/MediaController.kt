package com.example.p_lyric

import android.content.Context
import android.media.AudioManager
import android.util.Log
import android.view.KeyEvent
import androidx.core.content.ContextCompat.getSystemService
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.Exception

class MediaController(flutterEngine: FlutterEngine, context: Context) {
    companion object {
        private const val CHANNEL = "com.example.p_lyric/MusicProvider"
    }

    private var audioManager: AudioManager? = null

    init {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            val method = call.method
            result.success(
                when {
                    method.equals("play") -> control(KeyEvent.KEYCODE_MEDIA_PLAY)
                    method.equals("pause") -> control(KeyEvent.KEYCODE_MEDIA_PAUSE)
                    method.equals("skipPrevious") -> control(KeyEvent.KEYCODE_MEDIA_PREVIOUS)
                    method.equals("skipNext") -> control(KeyEvent.KEYCODE_MEDIA_NEXT)
                    else -> false
                }
            )
        }
        audioManager = getSystemService<AudioManager>(context, AudioManager::class.java)
    }

    private fun control(action: Int) : Boolean {
        try {
            if (audioManager != null) {
                val downEvent = KeyEvent(KeyEvent.ACTION_DOWN, action)
                audioManager!!.dispatchMediaKeyEvent(downEvent)

                val upEvent = KeyEvent(KeyEvent.ACTION_UP, action)
                audioManager!!.dispatchMediaKeyEvent(upEvent)
            } else {
                return false
            }
        } catch (e: Exception) {
            Log.e("MusicProvider", e.toString())
            return false
        }
        return true
    }
}