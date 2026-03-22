package com.example.renqing_ledger

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import com.baidu.paddle.lite.demo.ocr.OcrResultModel
import com.baidu.paddle.lite.demo.ocr.Predictor
import com.google.gson.Gson
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.InputStream

class PaddleOcrDelegate(
    private val activity: Activity,
    private var pendingResult: MethodChannel.Result? = null,
) {
    private val tag = "PaddleOcrDelegate"

    fun getOCRResultFromImage(imagePath: String) {
        try {
            val startTime = System.currentTimeMillis()
            val predictor = Predictor()
            predictor.init(
                activity.applicationContext,
                MODEL_PATH,
                LABEL_PATH,
                CPU_THREAD_NUM,
                CPU_POWER_MODE,
                INPUT_COLOR_FORMAT,
                INPUT_SHAPE,
                INPUT_MEAN,
                INPUT_STD,
                SCORE_THRESHOLD,
            )
            if (!predictor.isLoaded()) {
                pendingResult?.error("-1", "OCR 模型未加载", null)
                pendingResult = null
                return
            }

            if (imagePath.isEmpty()) {
                pendingResult?.error("-2", "图片路径为空", null)
                pendingResult = null
                predictor.releaseModel()
                return
            }

            val image = decodeBitmap(imagePath)
            if (image == null) {
                pendingResult?.error("-3", "图片不存在或无法读取", null)
                pendingResult = null
                predictor.releaseModel()
                return
            }

            predictor.setInputImage(image)
            if (!predictor.runModel()) {
                pendingResult?.error("-4", "PaddleOCR 推理失败", null)
                pendingResult = null
                predictor.releaseModel()
                return
            }

            val ocrResults = predictor.results.mapIndexed { index, model ->
                PaddleOcrResult(
                    index = index + 1,
                    name = model.label.orEmpty(),
                    confidence = model.confidence,
                    bounds = model.points.toMutableList(),
                )
            }
            val duration = System.currentTimeMillis() - startTime
            Log.i(tag, "PaddleOCR inference took ${duration}ms")
            pendingResult?.success(Gson().toJson(ocrResults))
            pendingResult = null
            predictor.releaseModel()
        } catch (e: Exception) {
            e.printStackTrace()
            pendingResult?.error("-5", e.message, null)
            pendingResult = null
        }
    }

    private fun decodeBitmap(imagePath: String): Bitmap? {
        return if (!imagePath.startsWith("/")) {
            val imageStream: InputStream = activity.assets.open(imagePath)
            BitmapFactory.decodeStream(imageStream)
        } else {
            val imageFile = File(imagePath)
            if (!imageFile.exists()) {
                null
            } else {
                BitmapFactory.decodeFile(imagePath)
            }
        }
    }

    companion object {
        private const val MODEL_PATH = "models/ocr_v1_for_cpu"
        private const val LABEL_PATH = "labels/ppocr_keys_v1.txt"
        private const val CPU_THREAD_NUM = 4
        private const val CPU_POWER_MODE = "LITE_POWER_HIGH"
        private const val INPUT_COLOR_FORMAT = "BGR"
        private val INPUT_SHAPE = longArrayOf(1, 3, 960)
        private val INPUT_MEAN = floatArrayOf(0.485f, 0.456f, 0.406f)
        private val INPUT_STD = floatArrayOf(0.229f, 0.224f, 0.225f)
        private const val SCORE_THRESHOLD = 0.1f
    }
}
