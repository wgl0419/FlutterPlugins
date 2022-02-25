package dev.flutter.qrscan_plugin.internal

interface QrScanListener {
    fun onFirstFrame() {}
    fun onLuminosity(luminosity: Double) {}
    fun onResult(result: QrScanResult) {}
}
