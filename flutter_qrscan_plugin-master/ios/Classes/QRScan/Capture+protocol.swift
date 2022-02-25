//
//  Capture+protocol.swift
//  QRScanDemo
//
//  Created by SimMan on 2021/10/25.
//

import Foundation
import UIKit

public protocol CaptureResultDelegate: AnyObject {
    func metadataOutputObjects(results: [QRResult], image: UIImage)
    func onBrightnessValueChange(value: CGFloat)
}
