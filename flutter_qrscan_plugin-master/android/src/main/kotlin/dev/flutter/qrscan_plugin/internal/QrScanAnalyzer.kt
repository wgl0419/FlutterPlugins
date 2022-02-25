package dev.flutter.qrscan_plugin.internal

import android.graphics.BitmapFactory
import android.os.Handler
import android.util.Size
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.zxing.BinaryBitmap
import com.google.zxing.RGBLuminanceSource
import com.google.zxing.common.HybridBinarizer

class QrScanAnalyzer(private val handler: Handler) : ImageAnalysis.Analyzer {

    companion object {
        private const val TAG = "QrScanAnalyzer"
        private const val FLAG_CALLED_FIRST_FRAME = 1 shl 0
        private const val FLAG_CALLED_RESULT = 1 shl 1
    }

    var listener: QrScanListener? = null

    @Volatile
    private var flags = 0

    private val isCalledFirstFrame get() = flags and FLAG_CALLED_FIRST_FRAME == FLAG_CALLED_FIRST_FRAME
    private val isCalledResult get() = flags and FLAG_CALLED_RESULT == FLAG_CALLED_RESULT

    private var cachePixels = IntArray(0)
    private var cacheYBytes = ByteArray(0)

    fun reset() = kotlin.run { flags = 0 }

    override fun analyze(image: ImageProxy) {
        if (!isCalledFirstFrame) {
            flags = flags or FLAG_CALLED_FIRST_FRAME
            handler.post { listener?.onFirstFrame() }
        }
        if (!isCalledResult) {
            val jpeg = ImageUtil.imageToJpegByteArray(image)
            if (jpeg != null) {
                val buffer = image.planes[0].buffer
                buffer.rewind()
                val remaining = buffer.remaining()
                if (cacheYBytes.size != remaining) {
                    cacheYBytes = ByteArray(remaining)
                }
                buffer.get(cacheYBytes)
                val luminosity = cacheYBytes.averagePositive() / 255.0
                handler.post { listener?.onLuminosity(luminosity) }
                val preview = BitmapFactory.decodeByteArray(jpeg, 0, jpeg.size).rotate(90f)
                val width = preview.width
                val height = preview.height
                if (cachePixels.size != width * height) {
                    cachePixels = IntArray(width * height)
                }
                preview.getPixels(cachePixels, 0, width, 0, 0, width, height)
                val source = RGBLuminanceSource(width, height, cachePixels)
                val binaryBitmap = BinaryBitmap(HybridBinarizer(source))
                val results = AnalyzeEngine.decodeMultiple(binaryBitmap)
                if (!results.isNullOrEmpty()) {
                    flags = flags or FLAG_CALLED_RESULT
                    val qrScanResult = QrScanResult(
                        results,
                        Size(preview.width, preview.height),
                        preview.toJpegBytes()
                    )
                    handler.post { listener?.onResult(qrScanResult) }
                }
                preview.recycle()
            }
        }
        image.close()
    }
}