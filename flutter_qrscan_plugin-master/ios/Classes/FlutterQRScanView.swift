//
//  QRScanPlatformView.swift
//  flutter_qrscan_plugin
//
//  Created by SimMan on 2021/11/24.
//

import Foundation
import Flutter
import AVFoundation

class FlutterQRScanViewFactory: NSObject, FlutterPlatformViewFactory {
    private var _messenger: FlutterBinaryMessenger;
    
    init(messenger: FlutterBinaryMessenger) {
        self._messenger = messenger
        super.init()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let scanView = FlutterQRScanView(frame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: _messenger);
        return scanView;
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
}

class FlutterQRScanView: NSObject, FlutterPlatformView {
    private var _scanView: QRScanPlatformView
    
    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger?) {
        _scanView = QRScanPlatformView(frame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: messenger!)
        _scanView.backgroundColor = .black
        super.init();
    }
    
    func view() -> UIView {
        return _scanView;
    }
    
}
