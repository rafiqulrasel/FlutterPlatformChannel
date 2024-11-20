package com.example.platformchannel

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink

class SensorHandler(private val sensorManager: SensorManager) {

    private var accelerometer: Sensor? = null
    private var eventSink: EventSink? = null

    init {
        // Initialize the accelerometer sensor
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
    }

    // Start listening to the sensor data
    fun startListening(eventSink: EventSink) {
        this.eventSink = eventSink
        sensorManager.registerListener(sensorEventListener, accelerometer, SensorManager.SENSOR_DELAY_UI)
    }

    // Stop listening to the sensor data
    fun stopListening() {
        sensorManager.unregisterListener(sensorEventListener)
        eventSink = null
    }

    private val sensorEventListener = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent?) {
            event?.let {
                if (it.sensor.type == Sensor.TYPE_ACCELEROMETER) {
                    val sensorData = mapOf(
                        "x" to it.values[0],
                        "y" to it.values[1],
                        "z" to it.values[2]
                    )
                    eventSink?.success(sensorData)
                }
            }
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
            // Handle accuracy changes if needed
        }
    }
}