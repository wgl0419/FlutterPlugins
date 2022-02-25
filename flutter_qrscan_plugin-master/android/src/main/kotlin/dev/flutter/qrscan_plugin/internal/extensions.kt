package dev.flutter.qrscan_plugin.internal

import android.graphics.Bitmap
import android.graphics.Matrix
import java.io.ByteArrayOutputStream

fun Bitmap.rotate(rotate: Float): Bitmap {
    val width = width
    val height = height
    val matrix = Matrix()
    matrix.setRotate(rotate)
    val newBmp = Bitmap.createBitmap(this, 0, 0, width, height, matrix, false)
    if (newBmp == this) {
        return newBmp
    }
    recycle()
    return newBmp
}

fun Bitmap.toJpegBytes(): ByteArray {
    val bos = ByteArrayOutputStream()
    this.compress(Bitmap.CompressFormat.JPEG, 100, bos)
    return bos.toByteArray()
}

fun ByteArray.averagePositive(): Double {
    var sum = 0.0
    var count = 0
    for (element in this) {
        sum += element.toInt() and 0xFF
        ++count
    }
    return if (count == 0) Double.NaN else sum / count
}