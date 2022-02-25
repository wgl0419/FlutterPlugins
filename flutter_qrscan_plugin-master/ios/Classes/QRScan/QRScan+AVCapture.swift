//
//  QRScan+AVCapture.swift
//  QRScanDemo
//
//  Created by SimMan on 2021/10/25.
//

import Foundation
import AVFoundation
import UIKit

extension AVCaptureDeviceInput {
    public class func deviceInput(withMediaType mediaType: AVMediaType, captureSession: AVCaptureSession) -> AVCaptureDeviceInput? {
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for deviceInput in inputs {
                if deviceInput.device.hasMediaType(mediaType) {
                    return deviceInput
                }
            }
        }
        return nil
    }
}

extension AVCaptureVideoOrientation {
    /// UIKit orientation equivalent type
    public var uikitType: UIDeviceOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        @unknown default:
            return .unknown
        }
    }

    internal static func avorientationFromUIDeviceOrientation(_ orientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        var avorientation: AVCaptureVideoOrientation = .portrait
        switch orientation {
        case .portrait:
            break
        case .landscapeLeft:
            avorientation = .landscapeRight
            break
        case .landscapeRight:
            avorientation = .landscapeLeft
            break
        case .portraitUpsideDown:
            avorientation = .portraitUpsideDown
            break
        default:
            break
        }
        return avorientation
    }
    
    internal static func uIImageOrientationFromUIDeviceOrientation(_ orientation: UIDeviceOrientation) -> UIImage.Orientation {
        switch orientation {
        case .portrait:
            return UIImage.Orientation.up
            break
        case .landscapeLeft:
            return UIImage.Orientation.right
            break
        case .landscapeRight:
            return UIImage.Orientation.left
            break
        case .portraitUpsideDown:
            return UIImage.Orientation.down
            break
        default:
            break
        }
        return UIImage.Orientation.up
    }
}
