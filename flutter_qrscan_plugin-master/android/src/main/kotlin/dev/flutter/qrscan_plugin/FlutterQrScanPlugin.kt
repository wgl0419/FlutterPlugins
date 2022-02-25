package dev.flutter.qrscan_plugin

import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import dev.flutter.qrscan_plugin.internal.AnalyzeEngine
import com.google.zxing.BarcodeFormat
import com.google.zxing.BinaryBitmap
import com.google.zxing.DecodeHintType
import com.google.zxing.RGBLuminanceSource
import com.google.zxing.common.HybridBinarizer
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** FlutterQrScanPlugin */
class FlutterQrScanPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "dev.flutter.qrscan_plugin/FlutterQrScanPlugin"
    }

    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        // 注册QrScanPlatformView
        binding.platformViewRegistry.registerViewFactory(
            QrScanPlatformView.VIEW_TYPE_ID,
            QrScanPlatformView.Factory(binding.binaryMessenger)
        )
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setPossibleFormats" -> handleSetPossibleFormats(call, result)
            "analyzeImage" -> handleAnalyzeImage(call, result)
        }
    }

    private fun handleSetPossibleFormats(call: MethodCall, result: MethodChannel.Result) {
        val formats = (call.arguments as List<*>).mapNotNull { format -> BarcodeFormat.values().firstOrNull { it.name == format } }
        AnalyzeEngine.hints = mapOf(
            DecodeHintType.POSSIBLE_FORMATS to formats
        )
        result.success(true)
    }

    private fun handleAnalyzeImage(call: MethodCall, result: MethodChannel.Result) {
        val path = call.arguments as String
        val bmp = BitmapFactory.decodeFile(path)
        val width = bmp.width
        val height = bmp.height
        val pixels = IntArray(width * height)
        bmp.getPixels(pixels, 0, width, 0, 0, width, height)
        bmp.recycle()
        val source = RGBLuminanceSource(width, height, pixels)
        val binaryBitmap = BinaryBitmap(HybridBinarizer(source))
        val results = AnalyzeEngine.decodeMultiple(binaryBitmap)
        val reply = results?.firstOrNull()?.let {
            mapOf(
                "text" to it.text,
                "barcodeFormat" to it.barcodeFormat.name,
                "points" to it.resultPoints.map { p -> floatArrayOf(p.x, p.y) }
            )
        }
        result.success(reply)
    }

}
