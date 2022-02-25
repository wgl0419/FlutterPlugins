package dev.flutter.qrscan_plugin

import android.content.Context
import android.view.View
import androidx.camera.core.TorchState
import androidx.core.content.ContextCompat
import dev.flutter.qrscan_plugin.internal.QrScanListener
import dev.flutter.qrscan_plugin.internal.QrScanResult
import dev.flutter.qrscan_plugin.internal.QrScanView
import io.flutter.plugin.common.*
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class QrScanPlatformView(
    private val messenger: BinaryMessenger,
    private val context: Context,
    private val viewId: Int,
    private val args: Any?
) : PlatformView, MethodChannel.MethodCallHandler, EventChannel.StreamHandler, QrScanListener {

    companion object {
        private const val TAG = "QrScanPlatformView"
        const val VIEW_TYPE_ID = "dev.flutter.qrscan_plugin/QrScanPlatformView"
    }

    private val qrScanView = QrScanView(context)
    private val methodChannel = MethodChannel(messenger, "$VIEW_TYPE_ID/method#$viewId")
    private val eventChannel = EventChannel(messenger, "$VIEW_TYPE_ID/event#$viewId")
    private var eventSink: EventChannel.EventSink? = null

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
        qrScanView.setQrScanListener(this)
    }

    override fun getView(): View {
        qrScanView.didOnResumed()
        qrScanView.startCamera()
        return qrScanView
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        qrScanView.setQrScanListener(null)
        qrScanView.stopCamera()
        qrScanView.didOnDestroyed()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startCamera" -> handleStartCamera(result)
            "stopCamera" -> handleStopCamera(result)
            "enableTorch" -> handleEnableTorch(call, result)
            "setLinearZoom" -> handleSetLinearZoom(call, result)
            "getTorchState" -> handleGetTorchState(result)
            "setContinueAnalyze" -> handleSetContinueAnalyze(result)
        }
    }

    private fun handleStartCamera(result: MethodChannel.Result) {
        qrScanView.startCamera()
        result.success(true)
    }

    private fun handleStopCamera(result: MethodChannel.Result) {
        qrScanView.stopCamera()
        result.success(true)
    }

    private fun handleEnableTorch(call: MethodCall, result: MethodChannel.Result) {
        val future = qrScanView.cameraControl?.enableTorch(call.arguments as Boolean)
        if (future == null) {
            result.success(false)
        } else {
            future.addListener(Runnable {
                result.success(true)
            }, ContextCompat.getMainExecutor(context))
        }
    }

    private fun handleSetLinearZoom(call: MethodCall, result: MethodChannel.Result) {
        val linearZoom = (call.arguments as Double).toFloat()
        if (linearZoom !in 0.0..1.0) {
            result.success(false)
            return
        }
        val future = qrScanView.cameraControl?.setLinearZoom((call.arguments as Double).toFloat())
        if (future == null) {
            result.success(false)
        } else {
            future.addListener(Runnable {
                result.success(true)
            }, ContextCompat.getMainExecutor(context))
        }
    }

    private fun handleGetTorchState(result: MethodChannel.Result) {
        result.success(qrScanView.camera?.cameraInfo?.torchState?.value == TorchState.ON)
    }


    private fun handleSetContinueAnalyze(result: MethodChannel.Result) {
        qrScanView.setContinueAnalyze()
        result.success(false)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onFirstFrame() {
        super.onFirstFrame()
        val event = mapOf(
            "action" to "onFirstFrame"
        )
        eventSink?.success(event)
    }

    override fun onLuminosity(luminosity: Double) {
        super.onLuminosity(luminosity)
        val event = mapOf(
            "action" to "onLuminosity",
            "luminosity" to luminosity
        )
        eventSink?.success(event)
    }

    override fun onResult(result: QrScanResult) {
        super.onResult(result)
        val results = result.results.map {
            mapOf(
                "text" to it.text,
                "barcodeFormat" to it.barcodeFormat.name,
                "points" to it.resultPoints.map { p -> floatArrayOf(p.x, p.y) }
            )
        }
        val event = mapOf(
            "action" to "onResult",
            "previewJpeg" to result.previewJpeg,
            "previewSize" to intArrayOf(result.previewSize.width, result.previewSize.height),
            "results" to results
        )
        eventSink?.success(event)
    }


    class Factory(
        private val messenger: BinaryMessenger
    ) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
            return QrScanPlatformView(messenger, context, viewId, args)
        }
    }


}