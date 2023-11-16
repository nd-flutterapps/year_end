package com.chidumennamdi.year_end

import android.app.Service
import android.content.Intent
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar
import java.util.Timer
import java.util.TimerTask

class YearCountdown: Service() {
    private var eventSink: EventChannel.EventSink? = null
    private var timer: Timer? = null
    private val CHANNEL_ID = "BirthdayChannel"

    private var eventChannel: EventChannel? = null
    private var methodChannel: MethodChannel? = null

    val CHANNEL_NAME = "com.chidumennamdi.year_end/countdown"
    val EVENT_CHANNEL_NAME= "com.chidumennamdi.year_end/stream_channel"

    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // This assumes that MainActivity.sharedFlutterEngine is properly initialized
        MainActivity.sharedFlutterEngine?.let { engine ->
            initializeEventChannel(engine.dartExecutor.binaryMessenger)
            initializeMethodChannel(engine.dartExecutor.binaryMessenger)
        } ?: println("Error: sharedFlutterEngine not initialized")

        println("Kotlin: initializing EventChannel")
        return START_STICKY
    }

    private fun initializeMethodChannel(messenger: BinaryMessenger) {
        println("initializeMethodChannel")

        methodChannel = MethodChannel(messenger, CHANNEL_NAME).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "startCountdown" -> {
                        startCountdown()
                        result.success(null)
                    }
                    "stopCountdown" -> {
                        stopCountdown()
                        // showNotification("", "Countdown stopped")
                    }
                    "reset" -> {
                        reset()
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }
    }

    private  fun reset() {
        timer?.cancel();
        startCountdown();
    }

    private fun startCountdown() {
        timer = Timer()
        timer!!.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                val countdownMillis = calculateTimeUntilYearEnd()
                sendEventToFlutter(countdownMillis.toString())
            }
        }, 1000, 1000)
    }

    fun calculateTimeUntilYearEnd(): Long {
        val today = Calendar.getInstance()
        val endOfYear = Calendar.getInstance()

        // Set the end of the year
        endOfYear.set(today.get(Calendar.YEAR), Calendar.DECEMBER, 31, 23, 59, 59)
        endOfYear.set(Calendar.MILLISECOND, 999)

        // Calculate the time until the end of the year
        return endOfYear.timeInMillis - today.timeInMillis
    }

    private fun initializeEventChannel(messenger: BinaryMessenger) {
        println("initializeEventChannel")
        // Set up EventChannel
        eventChannel = EventChannel(messenger, EVENT_CHANNEL_NAME).apply {
            setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
        }
    }

    private fun sendEventToFlutter(message: String) {
        mainHandler.post {
            eventSink?.success(message)
        }
    }
    private fun stopCountdown() {
        timer?.cancel();
    }

    override fun onDestroy() {
        super.onDestroy()
        timer?.cancel()
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }
}
