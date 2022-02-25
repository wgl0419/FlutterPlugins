package dev.flutter.qrscan_plugin.internal

import com.google.zxing.BinaryBitmap
import com.google.zxing.DecodeHintType
import com.google.zxing.MultiFormatReader
import com.google.zxing.Result
import com.google.zxing.multi.GenericMultipleBarcodeReader

object AnalyzeEngine {

    private val decoder = GenericMultipleBarcodeReader(MultiFormatReader())
    var hints: Map<DecodeHintType, *>? = null

    fun decodeMultiple(binaryBitmap: BinaryBitmap, hints: Map<DecodeHintType, *>? = null): List<Result>? {
        return kotlin.runCatching {
            decoder.decodeMultiple(binaryBitmap, hints ?: AnalyzeEngine.hints)
        }.getOrNull()?.toList()
    }

}