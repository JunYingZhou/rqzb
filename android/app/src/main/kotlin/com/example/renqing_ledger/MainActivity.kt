package com.example.renqing_ledger

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "paddle_ocr")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPlatformVersion" -> {
                        result.success("Android ${android.os.Build.VERSION.RELEASE}")
                    }

                    "ocrFromImage" -> {
                        val args = call.arguments as? Map<*, *>
                        val imagePath = args?.get("imagePath")?.toString()
                        if (imagePath.isNullOrBlank()) {
                            result.error("-2", "图片路径为空", null)
                            return@setMethodCallHandler
                        }
                        PaddleOcrDelegate(this, result).getOCRResultFromImage(imagePath)
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
