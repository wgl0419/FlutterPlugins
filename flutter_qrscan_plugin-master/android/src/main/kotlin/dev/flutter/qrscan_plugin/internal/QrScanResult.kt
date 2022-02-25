package dev.flutter.qrscan_plugin.internal

import android.util.Size
import com.google.zxing.Result

data class QrScanResult(
    val results: List<Result>,
    val previewSize: Size,
    val previewJpeg: ByteArray
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as QrScanResult

        if (results != other.results) return false
        if (!previewJpeg.contentEquals(other.previewJpeg)) return false

        return true
    }

    override fun hashCode(): Int {
        var result = results.hashCode()
        result = 31 * result + previewJpeg.contentHashCode()
        return result
    }
}