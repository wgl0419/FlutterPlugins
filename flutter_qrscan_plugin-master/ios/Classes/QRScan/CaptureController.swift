//
//  CaptureController.swift
//  QRScanDemo
//
//  Created by SimMan on 2021/10/25.
//

import Foundation
import AVFoundation
import UIKit

private let CaptureSessionQueueIdentifier = "dev.flutter.qrcode.CaptureSession"
class CaptureController: NSObject {

    private var _captureSession: AVCaptureSession!
    private var _captureDevice: AVCaptureDevice!
    private var _captureVideoInput: AVCaptureDeviceInput!
    private var _metadataOutput: AVCaptureMetadataOutput!
    private var _captureVideoOutput: AVCaptureVideoDataOutput!
    private var _sessionQueue: DispatchQueue!
    private var _videoPermissionService = VideoPermissionService();
    public var lastVideoFrame: CMSampleBuffer?
    private(set) public var isSessionRunning = false;
    private var backCameraDevice: AVCaptureDevice? {
        return AVCaptureDevice.default(for: .video)
    }
    
//    private(set) public var converter: RBarcodePixelConverter?
    
    public var canRecognition: Bool = true
    public var onFrameAvailable: (() -> Void)?
    public var videoPreviewLayer: AVCaptureVideoPreviewLayer
    public var metadataObjectTypes: [AVMetadataObject.ObjectType]?
    public var maximumVideoDuration: Double = 0.0
    public weak var metadataObjectsDelegate: CaptureResultDelegate?
    public typealias TorchMode = AVCaptureDevice.TorchMode
    
    override init() {
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer()
        self.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self._sessionQueue = DispatchQueue(label: CaptureSessionQueueIdentifier, qos: .userInteractive, target: DispatchQueue.global())
        self._sessionQueue.setSpecific(key: DispatchSpecificKey<()>(), value: ())
        super.init();
    }
    
    func start() {
        self._videoPermissionService.checkPersmission { result in
            if (result == nil) {
                self._setupCamera();
            }
        }
    }
    
    func stop() {
        if let session = self._captureSession {
            self._sessionQueue.async {
                if session.isRunning == true {
                    session.stopRunning()
                    self.isSessionRunning = false
                    self.canRecognition = false
                }

                session.beginConfiguration()
                
                self.removeInputs(session: session)
                self.removeOutputs(session: session)
                session.commitConfiguration()

                self._captureSession = nil
                self._captureDevice = nil
                self.lastVideoFrame = nil
//                self.converter = nil
            }
        }
    }
    
    func updateMetadataOutpuTrectOfInterest(rect: CGRect) {
        if let metadataOutput = self._metadataOutput {
            metadataOutput.rectOfInterest = rect;
        }
    }

    private func _setupCamera() {
        self._sessionQueue.async {
            self._captureSession = AVCaptureSession()
            
            if let session = self._captureSession {
                session.automaticallyConfiguresApplicationAudioSession = false
                
                session.beginConfiguration()
                
                self.videoPreviewLayer.session = session
                session.sessionPreset = AVCaptureSession.Preset.hd1280x720
                _ = self.addVideoOutput()
                self.updateCameraDevice()
                self.configureSessionDevices()
                self.configureMetadataObjects()
                self.updateVideoOrientation()
                
                session.commitConfiguration()
                
                if session.isRunning == false {
                    session.startRunning()
                    self.isSessionRunning = true
                    self.canRecognition = true
                }
            }
        }
    }
    
    private func configureMetadataObjects() {
        guard let session = self._captureSession else {
            return
        }

        guard let metadataObjectTypes = metadataObjectTypes,
            metadataObjectTypes.count > 0 else {
                return
        }

        if self._metadataOutput == nil {
            self._metadataOutput = AVCaptureMetadataOutput()
        }

        guard let metadataOutput = self._metadataOutput else {
            return
        }

        if !session.outputs.contains(metadataOutput),
            session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

            let availableTypes = metadataObjectTypes.filter { type in
                metadataOutput.availableMetadataObjectTypes.contains(type)
            }

            metadataOutput.metadataObjectTypes = availableTypes
        }
    }
    
    private func configureSessionDevices() {
        guard let session = self._captureSession else {
            return
        }
        
        guard let captureDevice = self._captureDevice else {
            return
        }
        
//        let format = self._captureDevice.activeFormat
//        let formatDescription = format.formatDescription
//        let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
//        self.videoPreviewLayer.frame = CGRect(x: 0, y: 0, width: CGFloat(dimensions.height), height: CGFloat(dimensions.width))
//        self.converter = RBarcodePixelConverter(size: CGFloat(dimensions.height), height: CGFloat(dimensions.width))
                
        if let currentDeviceInput = AVCaptureDeviceInput.deviceInput(withMediaType: .video, captureSession: session) {
            session.removeInput(currentDeviceInput)
        }
        
        do {
            try captureDevice.lockForConfiguration()

            if captureDevice.isFocusModeSupported(.continuousAutoFocus) {
                captureDevice.focusMode = .continuousAutoFocus
                if captureDevice.isSmoothAutoFocusSupported {
                    captureDevice.isSmoothAutoFocusEnabled = true
                }
            }

            if captureDevice.isExposureModeSupported(.continuousAutoExposure) {
                captureDevice.exposureMode = .continuousAutoExposure
            }

            if captureDevice.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                captureDevice.whiteBalanceMode = .continuousAutoWhiteBalance
            }

            captureDevice.isSubjectAreaChangeMonitoringEnabled = true

            if captureDevice.isLowLightBoostSupported {
                captureDevice.automaticallyEnablesLowLightBoostWhenAvailable = true
            }
            captureDevice.unlockForConfiguration()
        } catch {
            print("low light failed to lock device for configuration")
        }
        
        _ = self.addInput(session: session, device: captureDevice)
    }
    
    private func addInput(session: AVCaptureSession, device: AVCaptureDevice) -> Bool {
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)

                if input.device.hasMediaType(AVMediaType.video) {
                    self._captureVideoInput = input
                }

                return true
            }
        } catch {
            print("failure adding input device")
        }
        return false
    }

    private func removeInputs(session: AVCaptureSession) {
        if let inputs = session.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                session.removeInput(input)
            }
            self._captureVideoInput = nil
        }
    }
    
    private func removeOutputs(session: AVCaptureSession) {
        for output in session.outputs {
            session.removeOutput(output)
        }

        self._captureVideoOutput = nil
        self._metadataOutput = nil
    }
    
    private func addVideoOutput() -> Bool {
        if self._captureVideoOutput == nil {
            self._captureVideoOutput = AVCaptureVideoDataOutput()
            self._captureVideoOutput?.alwaysDiscardsLateVideoFrames = true

            var videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA)]
            #if !( targetEnvironment(simulator) )
                if let formatTypes = self._captureVideoOutput?.availableVideoPixelFormatTypes {
                    var supportsFullRange = false
                    var supportsVideoRange = false
                    for format in formatTypes {
                        if format == Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
                            supportsFullRange = true
                        }
                        if format == Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
                            supportsVideoRange = true
                        }
                    }
                    if supportsFullRange {
                        videoSettings[String(kCVPixelBufferPixelFormatTypeKey)] = Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
                    } else if supportsVideoRange {
                        videoSettings[String(kCVPixelBufferPixelFormatTypeKey)] = Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
                    }
                }
            #endif
            self._captureVideoOutput?.videoSettings = videoSettings
        }

        if let session = self._captureSession, let videoOutput = self._captureVideoOutput {
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: self._sessionQueue)
                return true
            }
        }
        print("couldn't add video output to session")
        return false

    }
    
    private func updateVideoOrientation() {
        let currentOrientation = AVCaptureVideoOrientation.avorientationFromUIDeviceOrientation(UIDevice.current.orientation)

        if let previewConnection = self.videoPreviewLayer.connection {
            if previewConnection.isVideoOrientationSupported && previewConnection.videoOrientation != currentOrientation {
                previewConnection.videoOrientation = currentOrientation
            }
        }

        if let videoOutput = self._captureVideoOutput, let videoConnection = videoOutput.connection(with: AVMediaType.video) {
            if videoConnection.isVideoOrientationSupported && videoConnection.videoOrientation != currentOrientation {
                videoConnection.videoOrientation = currentOrientation
            }
        }
    }
    
    private func updateCameraDevice() {
        self._captureDevice = self.backCameraDevice;
        
        if let validCaptureSession = self._captureSession {
            validCaptureSession.beginConfiguration()
            defer { validCaptureSession.commitConfiguration() }
            let inputs: [AVCaptureInput] = validCaptureSession.inputs

            for input in inputs {
                if let deviceInput = input as? AVCaptureDeviceInput {
                    validCaptureSession.removeInput(deviceInput)
                }
            }

            if let validBackDevice = deviceInputFromDevice(backCameraDevice),
                !inputs.contains(validBackDevice) {
                validCaptureSession.addInput(validBackDevice)
            }
        }
    }
        
    private func deviceInputFromDevice(_ device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let outError {
            print(outError)
            return nil
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate
extension CaptureController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if (!self.canRecognition) {
            return
        }
        self.lastVideoFrame = sampleBuffer
        switch UIDevice.current.orientation {
        case .landscapeRight:
            connection.videoOrientation = .landscapeLeft
        case .landscapeLeft:
            connection.videoOrientation = .landscapeRight
        case .portrait:
            connection.videoOrientation = .portrait
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
        default:
            connection.videoOrientation = .portrait
        }
        
        if (self.onFrameAvailable != nil) {
            self.onFrameAvailable!()
        }
        
        guard let delegate = self.metadataObjectsDelegate else { return }

        delegate.onBrightnessValueChange(value: sampleBuffer.brightness())
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if (!self.canRecognition) {
            return
        }
        
        self.canRecognition = false
        
        guard let delegate = self.metadataObjectsDelegate else { return }
        
        if (metadataObjects.isEmpty) {
            return
        }
        
        var result: [QRResult] = []
        
        for metadataObject in metadataObjects as [AVMetadataObject] {
            guard let transformedMetadataObject = self.videoPreviewLayer.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject else { continue }
            
            var points: [[Double]] = [];
            for corner in transformedMetadataObject.corners {
                points.append([Double(corner.x), Double(corner.y)])
            }
            result.append(QRResult(barcodeFormat: transformedMetadataObject.type.toStringName(), text: transformedMetadataObject.stringValue ?? "", points: points))
            
        }
        
        let currentOrientation = AVCaptureVideoOrientation.uIImageOrientationFromUIDeviceOrientation(UIDevice.current.orientation)
        let image = self.lastVideoFrame?.imageWithCGImage(orientation: currentOrientation)
        
        delegate.metadataOutputObjects(results: result, image: image!)
    }
}

// MARK: - flash and torch
extension CaptureController {
    
    public var isFlashAvailable: Bool {
        if let device: AVCaptureDevice = self._captureDevice {
            return device.hasFlash && device.isFlashAvailable
        }
        return false
    }
    
    public var isTorchAvailable: Bool {
        get {
            if let device = self._captureDevice {
                return device.hasTorch
            }
            return false
        }
    }
    
    public var torchMode: TorchMode {
        get {
            if let device: AVCaptureDevice = self._captureDevice {
                return device.torchMode
            }
            return .off
        }
        set {
            self._sessionQueue.async {
                guard let device = self._captureDevice,
                    device.hasTorch,
                    device.torchMode != newValue
                    else {
                        return
                }

                do {
                    try device.lockForConfiguration()
                    if device.isTorchModeSupported(newValue) {
                        device.torchMode = newValue
                    }
                    device.unlockForConfiguration()
                } catch {
                    print("torchMode failed to lock device for configuration")
                }
            }
        }
    }
}

