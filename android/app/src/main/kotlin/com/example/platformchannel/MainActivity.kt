package com.example.platformchannel

import android.content.pm.PackageManager
import android.hardware.SensorManager
import android.os.Build
import android.view.Gravity
import android.widget.Toast
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.common.StringCodec


class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.example.app/version"
        private const val SENSOR_STREAM_CHANNEL = "com.example.app/sensorStream"
        private lateinit var sensorHandler: SensorHandler
        private lateinit var sensorManager: SensorManager

    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
            // Initialize the sensor manager
        sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
        sensorHandler = SensorHandler(sensorManager)
        // Register an event channel
        val eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, SENSOR_STREAM_CHANNEL)

        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                // Start listening to sensor data when Flutter listens to the stream
                events?.let { sensorHandler.startListening(it) }
            }

            override fun onCancel(arguments: Any?) {
                // Stop listening to sensor data when Flutter cancels the stream
                sensorHandler.stopListening()
            }
        })

        // Register a method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getVersionInfo") {
                try {
                    // Retrieve package information
                    val packageInfo = packageManager.getPackageInfo(packageName, 0)
                    val versionName = packageInfo.versionName
                    val versionCode = packageInfo.versionCode // Updated for API 28+

                    // Return the version info as a map
                    result.success(
                        mapOf(
                            "versionName" to versionName,
                            "versionCode" to versionCode
                        )
                    )
                } catch (e: PackageManager.NameNotFoundException) {
                    result.error("UNAVAILABLE", "Version info not available", null)
                }
            }else if (call.method == "showToast"){
                val message = call.argument<String>("message")
                val toast=Toast.makeText(this, message, Toast.LENGTH_SHORT)
                toast.setGravity(Gravity.TOP, 120, 0)
                toast.show()
                //result.success(message)

            } else {
                result.notImplemented()
            }
        }

        // Create a BasicMessageChannel with StringCodec
        val messageChannel = BasicMessageChannel<String>(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.basic/message",
            StringCodec.INSTANCE
        )

        // Handle incoming messages
        messageChannel.setMessageHandler { message, reply ->
            println("Received from Flutter: $message")
            reply.reply("Hello from Android!")
        }

        // Create a BasicMessageChannel with StandardMessageCodec
        val messageChannelAdvanced = BasicMessageChannel<Any?>(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.advanced/message",
            StandardMessageCodec.INSTANCE
        )

        messageChannelAdvanced.setMessageHandler { message, reply ->
            if (message is Map<*, *>) {
                println("Received from Flutter: $message")

                // Process the map
                val response = mutableMapOf<String, Any?>()
                response.putAll(message as Map<String, Any?>)
                response["processed"] = true
                response["status"] = "success"

                reply.reply(response)
            } else {
                println("Invalid message format")
                reply.reply(mapOf("error" to "Invalid message format"))
            }
        }

        }



}
