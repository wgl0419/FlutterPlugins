package dev.flutter.qrscan_plugin.internal

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import android.util.Log
import android.util.Size
import android.view.Surface
import android.widget.FrameLayout
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import java.util.concurrent.Executors

class QrScanView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : FrameLayout(context, attrs), LifecycleOwner {

    companion object {
        private const val TAG = "QrScanView"
    }

    private val lifecycle = LifecycleRegistry(this)
    private val cameraExecutor = Executors.newSingleThreadExecutor()
    private val previewView = PreviewView(context)
    private val mainHandler by lazy { Handler(Looper.getMainLooper()) }

    private val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA

    // Preview
    private lateinit var previewUseCase: Preview

    // Analysis
    private val qrScanAnalyzer = QrScanAnalyzer(mainHandler)
    private lateinit var imageAnalyzerUseCase: ImageAnalysis

    var camera: Camera? = null
        private set
    private var cameraProvider: ProcessCameraProvider? = null

    init {
        addView(previewView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        post {
            val targetResolution = Size(width, height)
            previewUseCase = Preview.Builder()
                .setTargetRotation(Surface.ROTATION_0)
                .setTargetResolution(targetResolution)
                .build()
                .also { it.setSurfaceProvider(previewView.surfaceProvider) }
            imageAnalyzerUseCase = ImageAnalysis.Builder()
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .setTargetRotation(Surface.ROTATION_0)
                .setTargetResolution(targetResolution)
                .build()
                .also { it.setAnalyzer(cameraExecutor, qrScanAnalyzer) }
        }
    }

    override fun getLifecycle(): Lifecycle = lifecycle

    val cameraControl: CameraControl? get() = camera?.cameraControl

    fun setQrScanListener(listener: QrScanListener?) {
        qrScanAnalyzer.listener = listener
    }

    fun didOnResumed() {
        lifecycle.currentState = Lifecycle.State.RESUMED
    }

    fun didOnDestroyed() {
        lifecycle.currentState = Lifecycle.State.DESTROYED
        cameraExecutor.shutdown()
    }

    fun setContinueAnalyze() {
        qrScanAnalyzer.reset()
    }

    fun startCamera() = post {
        qrScanAnalyzer.reset()
        if (cameraProvider != null) {
            internalStartCamera(cameraProvider!!)
        } else {
            val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
            cameraProviderFuture.addListener(Runnable {
                cameraProvider = cameraProviderFuture.get()
                internalStartCamera(cameraProvider!!)
            }, ContextCompat.getMainExecutor(context))
        }
    }

    fun stopCamera() = post {
        cameraProvider?.unbindAll()
        camera = null
    }

    private fun internalStartCamera(cameraProvider: ProcessCameraProvider) {
        try {
            cameraProvider.unbindAll()
            camera = cameraProvider.bindToLifecycle(
                this,
                cameraSelector,
                previewUseCase,
                imageAnalyzerUseCase
            )
        } catch (e: Exception) {
            Log.e(TAG, "Use case binding failed", e)
        }
    }


}

