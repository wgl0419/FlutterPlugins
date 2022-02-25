//
//  Capture+MetadataObject.swift
//  QRScanDemo
//
//  Created by SimMan on 2021/10/25.
//

import Foundation
import AVFoundation

extension AVMetadataObject.ObjectType {
    func toStringName() -> String {
        switch self {
        case .aztec:
            return "AZTEC"
        case .code39:
            return "CODE_39"
        case .code93:
            return "CODE_93"
        case .code128:
            return "CODE_128"
        case .dataMatrix:
            return "DATA_MATRIX"
        case .ean8:
            return "EAN_8"
        case .ean13:
            return "EAN_13"
        case .itf14:
            return "ITF"
        case .pdf417:
            return "PDF_417"
        case .qr:
            return "QR_CODE"
        case .upce:
            return "UPC_E"
        default:
            return "other"
        }
    }
}
