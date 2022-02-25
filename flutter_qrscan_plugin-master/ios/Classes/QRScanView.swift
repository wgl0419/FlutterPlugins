//
//  QRScanView.swift
//  flutter_qrscan_plugin
//
//  Created by SimMan on 2021/10/25.
//

import Foundation
import Flutter
import CoreMedia
import CoreImage
import ZXingObjC

class QRScanView: NSObject, FlutterTexture, CaptureResultDelegate {
    private let channelName = "dev.flutter.qrscan_plugin/QrScanPlatformView"
    private let pluginChannelName = "dev.flutter.qrscan_plugin/FlutterQrScanPlugin"
    
    var textureRegistry: FlutterTextureRegistry
    var binaryMessager: FlutterBinaryMessenger
    private var _captureController: CaptureController?
    private var _channel: FlutterMethodChannel
    private var _pluginChannel: FlutterMethodChannel
    private var _eventChannel: FlutterEventChannel?
    private var _events: FlutterEventSink?
    
    private var _isSendOnFrameAvailable: Bool = false
    
    init(textureRegistry: FlutterTextureRegistry, binaryMessager: FlutterBinaryMessenger) {
        self.binaryMessager = binaryMessager
        self.textureRegistry = textureRegistry
        self._channel = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessager)
        self._pluginChannel = FlutterMethodChannel(name: pluginChannelName, binaryMessenger: binaryMessager)
        super.init()
        _channel.setMethodCallHandler(handle(_:result:))
        _pluginChannel.setMethodCallHandler(handle(_:result:))
    }
    
    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        guard let controller = _captureController else { return nil }
        guard let lastVideoFrame = controller.lastVideoFrame, let _latestPixelBuffer = CMSampleBufferGetImageBuffer(lastVideoFrame) else { return nil }
        return Unmanaged<CVPixelBuffer>.passRetained(_latestPixelBuffer)
//        return self._captureController?.converter?.convertResult(_latestPixelBuffer)
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("flutter handle method: \(call.method)")
        switch call.method {
        case "initialize":
            initializeCamera(result: result)
        case "getTorchState":
            result(NSNumber.init(value: self._captureController?.torchMode == .on))
        case "enableTorch":
            let enable = call.arguments as? Bool
            if (enable == true) {
                self._captureController?.torchMode = .on
            } else {
                self._captureController?.torchMode = .off
            }
            result(NSNumber.init(value: true));
        case "stopCamera":
            self._captureController?.stop()
        case "startCamera":
            self._isSendOnFrameAvailable = false
            self._captureController?.start()
        case "setContinueAnalyze":
            self._captureController?.canRecognition = true
        case "analyzeImage":
            analyzeImage(call, result: result)
        default:
            break
        }
    }
    
    func initializeCamera(result: @escaping FlutterResult) {
        self._captureController = CaptureController.init()
        _captureController?.metadataObjectsDelegate = self
        _captureController?.metadataObjectTypes = [.qr, .code39, .aztec, .code128, .code93, .dataMatrix, .ean13, .ean8]
        let textureId = self.textureRegistry.register(self)
        _captureController?.onFrameAvailable = {
            self.textureRegistry.textureFrameAvailable(textureId)
            if (!self._isSendOnFrameAvailable) {
                self._isSendOnFrameAvailable = true
                self._events?(["action": "onFirstFrame"])
            }
        }
        self._eventChannel = FlutterEventChannel(name: "\(channelName)/event#\(textureId)", binaryMessenger: binaryMessager)
        self._eventChannel?.setStreamHandler(self)
        _captureController?.start()
        result(NSNumber.init(value: textureId))
    }
    
    func metadataOutputObjects(results: [QRResult], image: UIImage) {
        self._captureController?.canRecognition = false
        let result = [
            "action": "onResult",
            "previewJpeg": FlutterStandardTypedData.init(bytes: image.jpegData(compressionQuality: 90)!),
            "previewSize": [Float(image.size.width), Float(image.size.height)],
            "results": results.map { $0.toMap() }
        ] as [String : Any]
        self._events?(result);
        
    }
    
    func onBrightnessValueChange(value: CGFloat) {
        self._events?(["action": "onLuminosity", "luminosity": Float.init(value)]);
    }
    
    func analyzeImage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let image = UIImage.init(contentsOfFile: call.arguments as! String), let cgImage = image.cgImage else { return }

        let ciImage = CIImage(cgImage: cgImage)
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: CIContext(options: nil), options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: ciImage)
        if let feature = features?.first as? CIQRCodeFeature, let code = feature.messageString {
            let points: [[Double]] = [
                [Double(feature.topLeft.x), Double(feature.topLeft.y)],
                [Double(feature.topRight.x), Double(feature.topRight.y)],
                [Double(feature.bottomLeft.x), Double(feature.bottomLeft.y)],
                [Double(feature.bottomRight.x), Double(feature.bottomRight.y)],
            ];
            result([
                "text": code,
                "barcodeFormat": "QR_CODE",
                "points": points
            ])
            return
        }
    
        guard let fixOrientImage: UIImage = UIImage.fixedOrientation(for: image) else { return }
        let scaledImage = QRScanUtils.scaledImage(fixOrientImage, maxWidth: 1080, maxHeight: 1080)
        
        let source = ZXCGImageLuminanceSource(cgImage: scaledImage.cgImage)
        if let binary = ZXHybridBinarizer.init(source: source!) {
            let bitmap = ZXBinaryBitmap.init(binarizer: binary)
            let hints = ZXDecodeHints.hints() as! ZXDecodeHints
            let reader = ZXMultiFormatReader.reader() as! ZXReader
            // let multipleReader = ZXGenericMultipleBarcodeReader(delegate: reader)

            do {
                // let results = try multipleReader?.decodeMultiple(bitmap, hints: hints)
                let _zxResult = try reader.decode(bitmap, hints: hints) as ZXResult
                let _zxResultPoints = _zxResult.resultPoints as! [ZXResultPoint]
                let points = _zxResultPoints.map { $0.pointArray() }
                
                result([
                    "text": _zxResult.text ?? "",
                    "barcodeFormat": _zxResult.barcodeFormat.stringValue(),
                    "points": points
                ])
            } catch {
                print("\(error)")
                result(nil)
            }
        }
    }
}

// MARK: - FlutterStreamHandler
extension QRScanView: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self._events = events;
        return nil;
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self._events = nil;
        return nil;
    }
}
