import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.preference.PreferenceManager
import android.util.Log
import com.baidu.paddle.lite.demo.ocr.OcrResultModel
import com.baidu.paddle.lite.demo.ocr.Predictor
import com.baidu.paddle.lite.demo.ocr.Utils
import com.google.gson.Gson
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import viz.flutter.plugin.paddle_ocr.OcrResult
import viz.flutter.plugin.paddle_ocr.R
import java.io.File
import java.io.InputStream

class PaddleOCRDelegate(private val activity: Activity,
                        private var pendingResult: MethodChannel.Result? = null,
                        private var methodCall: MethodCall? = null
) : PluginRegistry.ActivityResultListener {
    private val TAG = "PaddleFaceDelegate"

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return true
    }

    // Model settings of object detection
    protected var modelPath = ""
    protected var labelPath = ""
    protected var imagePath = ""
    protected var cpuThreadNum = 1
    protected var cpuPowerMode = ""
    protected var inputColorFormat = ""
    protected var inputShape = longArrayOf()
    protected var inputMean = floatArrayOf()
    protected var inputStd = floatArrayOf()
    protected var scoreThreshold = 0.1f
    private val currentPhotoPath: String? = null

    fun initConfig() {
        val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(activity)
        var settingsChanged = false
        val model_path = sharedPreferences.getString(activity.getString(R.string.MODEL_PATH_KEY),
                activity.getString(R.string.MODEL_PATH_DEFAULT))
        val label_path = sharedPreferences.getString(activity.getString(R.string.LABEL_PATH_KEY),
                activity.getString(R.string.LABEL_PATH_DEFAULT))
        val image_path = sharedPreferences.getString(activity.getString(R.string.IMAGE_PATH_KEY),
                activity.getString(R.string.IMAGE_PATH_DEFAULT))
        settingsChanged = settingsChanged or !model_path.equals(modelPath, ignoreCase = true)
        settingsChanged = settingsChanged or !label_path.equals(labelPath, ignoreCase = true)
        settingsChanged = settingsChanged or !image_path.equals(imagePath, ignoreCase = true)
        val cpu_thread_num = sharedPreferences.getString(activity.getString(R.string.CPU_THREAD_NUM_KEY),
                activity.getString(R.string.CPU_THREAD_NUM_DEFAULT))!!.toInt()
        settingsChanged = settingsChanged or (cpu_thread_num != cpuThreadNum)
        val cpu_power_mode = sharedPreferences.getString(activity.getString(R.string.CPU_POWER_MODE_KEY),
                activity.getString(R.string.CPU_POWER_MODE_DEFAULT))
        settingsChanged = settingsChanged or !cpu_power_mode.equals(cpuPowerMode, ignoreCase = true)
        val input_color_format = sharedPreferences.getString(activity.getString(R.string.INPUT_COLOR_FORMAT_KEY),
                activity.getString(R.string.INPUT_COLOR_FORMAT_DEFAULT))
        settingsChanged = settingsChanged or !input_color_format.equals(inputColorFormat, ignoreCase = true)
        val input_shape = Utils.parseLongsFromString(sharedPreferences.getString(activity.getString(R.string.INPUT_SHAPE_KEY),
                activity.getString(R.string.INPUT_SHAPE_DEFAULT)), ",")
        val input_mean = Utils.parseFloatsFromString(sharedPreferences.getString(activity.getString(R.string.INPUT_MEAN_KEY),
                activity.getString(R.string.INPUT_MEAN_DEFAULT)), ",")
        val input_std = Utils.parseFloatsFromString(sharedPreferences.getString(activity.getString(R.string.INPUT_STD_KEY), activity.getString(R.string.INPUT_STD_DEFAULT)), ",")
        settingsChanged = settingsChanged or (input_shape.size != inputShape.size)
        settingsChanged = settingsChanged or (input_mean.size != inputMean.size)
        settingsChanged = settingsChanged or (input_std.size != inputStd.size)
        if (!settingsChanged) {
            for (i in input_shape.indices) {
                settingsChanged = settingsChanged or (input_shape[i] != inputShape.get(i))
            }
            for (i in input_mean.indices) {
                settingsChanged = settingsChanged or (input_mean[i] != inputMean.get(i))
            }
            for (i in input_std.indices) {
                settingsChanged = settingsChanged or (input_std[i] != inputStd.get(i))
            }
        }
        val score_threshold = sharedPreferences.getString(activity.getString(R.string.SCORE_THRESHOLD_KEY),
                activity.getString(R.string.SCORE_THRESHOLD_DEFAULT))!!.toFloat()
        settingsChanged = settingsChanged or (scoreThreshold != score_threshold)
        if (settingsChanged) {
            modelPath = model_path!!
            labelPath = label_path!!
            imagePath = image_path!!
            cpuThreadNum = cpu_thread_num
            cpuPowerMode = cpu_power_mode!!
            inputColorFormat = input_color_format!!
            inputShape = input_shape
            inputMean = input_mean
            inputStd = input_std
            scoreThreshold = score_threshold
        }
    }

    fun getOCRResultFromImage(imagePath: String) {
        try {
            val startTime = System.currentTimeMillis()
            var results = mutableListOf<OcrResultModel>()
            var ocrStr = ""
            val predictor = Predictor()
            initConfig()
            predictor.init(activity.applicationContext, modelPath, labelPath, cpuThreadNum,
                    cpuPowerMode,
                    inputColorFormat,
                    inputShape, inputMean,
                    inputStd, scoreThreshold)
            if (predictor.isLoaded()) {
                if (imagePath.isNotEmpty()) {
                    var image: Bitmap? = null
                    // read test image file from custom file_paths if the first character of mode file_paths is '/', otherwise read test
                    // image file from assets
                    image = if (imagePath.substring(0, 1) != "/") {
                        val imageStream: InputStream = activity.assets.open(imagePath)
                        BitmapFactory.decodeStream(imageStream)
                    } else {
                        if (!File(imagePath).exists()) {
                            pendingResult?.error("-3", "图片不存在", null)
                            clearMethodCallAndResult()
                            return
                        }
                        BitmapFactory.decodeFile(imagePath)
                    }
                    if (image != null) {
                        predictor.setInputImage(image)
                        if (predictor.runModel()) {
                            results = predictor.results
                            val ocrResults: MutableList<OcrResult> = java.util.ArrayList()
                            for (i in results.indices) {
                                val mOcrResultModel = results[i]
                                mOcrResultModel?.apply {
                                    ocrResults.add(OcrResult(i + 1, label, confidence, points))
                                }
                            }
                            val gson = Gson()
                            ocrStr = gson.toJson(ocrResults)
                        }
                    }
                } else {
                    pendingResult?.error("-2", "图片路径为空", null)
                    clearMethodCallAndResult()
                    return
                }
            } else {
                pendingResult?.error("-1", "识别模块未加载", null)
                clearMethodCallAndResult()
                return
            }

            predictor.releaseModel()
            val endTime = System.currentTimeMillis()
            Log.i(TAG, "OCR识别耗时:${endTime - startTime}ms")
            pendingResult?.success(ocrStr)
            clearMethodCallAndResult()
        } catch (e: Exception) {
            e.printStackTrace()
            pendingResult?.error("-4", e.message, null)
            clearMethodCallAndResult()
        }
    }

    private fun clearMethodCallAndResult() {
        methodCall = null
        pendingResult = null
    }
}