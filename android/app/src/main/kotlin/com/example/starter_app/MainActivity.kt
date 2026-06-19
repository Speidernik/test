package com.example.starter_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

// Zebra DataWedge setup:
// 1. DataWedge → create/edit profile → associate app: com.example.starter_app
// 2. Enable "Intent output"
// 3. Intent action: com.starter_app.ACTION_SCAN
// 4. Intent delivery: Broadcast intent
// Barcode value arrives in extra key: com.symbol.datawedge.data_string
class MainActivity : FlutterActivity() {

    private companion object {
        const val SCAN_CHANNEL = "com.example.starter_app/scanner"
        const val DW_ACTION = "com.starter_app.ACTION_SCAN"
        const val DW_DATA_KEY = "com.symbol.datawedge.data_string"
    }

    private var scanEventSink: EventChannel.EventSink? = null

    private val scanReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val data = intent.getStringExtra(DW_DATA_KEY) ?: return
            runOnUiThread { scanEventSink?.success(data) }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SCAN_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    scanEventSink = events
                    val filter = IntentFilter(DW_ACTION)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        registerReceiver(scanReceiver, filter, RECEIVER_EXPORTED)
                    } else {
                        @Suppress("UnspecifiedRegisterReceiverFlag")
                        registerReceiver(scanReceiver, filter)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    try { unregisterReceiver(scanReceiver) } catch (_: Exception) {}
                    scanEventSink = null
                }
            })
    }

    override fun onDestroy() {
        super.onDestroy()
        try { unregisterReceiver(scanReceiver) } catch (_: Exception) {}
    }
}
