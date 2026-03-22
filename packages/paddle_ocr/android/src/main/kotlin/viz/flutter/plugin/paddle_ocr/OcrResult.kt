package viz.flutter.plugin.paddle_ocr
import android.graphics.Point
import android.os.Parcelable
import kotlinx.android.parcel.Parcelize

/**
 * @title: OcrResult
 * @projectName android
 * @description:
 * @author zhangwei
 * @date 2020/9/30 15:13
 */
@Parcelize
data class OcrResult(var index:Int,var name:String,var confidence:Float,var bounds:MutableList<Point>) : Parcelable