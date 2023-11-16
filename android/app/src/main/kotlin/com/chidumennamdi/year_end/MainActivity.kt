package com.chidumennamdi.year_end

import android.content.Intent
import android.os.Bundle
import android.os.PersistableBundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.chidumennamdi.year_end/background_service"

    companion object {
        var sharedFlutterEngine: FlutterEngine? = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        flutterEngine?.dartExecutor?.binaryMessenger?.let {
            MethodChannel(it, CHANNEL)
                .setMethodCallHandler { call, result ->
                    if (call.method == "startBackgroundService") {
                        startService(Intent(this, YearCountdown::class.java))
                        result.success(null)
                    } else {
                        result.notImplemented()
                    }
                }
        }
        sharedFlutterEngine = flutterEngine

    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
    }
}
