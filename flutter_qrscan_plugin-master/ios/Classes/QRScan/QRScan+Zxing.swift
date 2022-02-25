//
//  QRScan+Zxing.swift
//  flutter_qrscan_plugin
//
//  Created by SimMan on 2021/10/26.
//

import Foundation
import ZXingObjC

extension ZXBarcodeFormat {
    func stringValue() -> String {
        switch self {
        case kBarcodeFormatAztec:
            return "AZTEC"
        case kBarcodeFormatCodabar:
            return "CODABAR"
        case kBarcodeFormatCode39:
            return "CODE_39"
        case kBarcodeFormatCode93:
            return "CODE_93"
        case kBarcodeFormatCode128:
            return "CODE_128"
        case kBarcodeFormatDataMatrix:
            return "DATA_MATRIX"
        case kBarcodeFormatEan8:
            return "DATA_MATRIX"
        case kBarcodeFormatEan13:
            return "EAN_13"
        case kBarcodeFormatITF:
            return "ITF"
        case kBarcodeFormatMaxiCode:
            return "MAXICODE"
        case kBarcodeFormatPDF417:
            return "MAXICODE"
        case kBarcodeFormatQRCode:
            return "QR_CODE"
        case kBarcodeFormatRSS14:
            return "RSS_14"
        case kBarcodeFormatRSSExpanded:
            return "RSS_EXPANDED"
        case kBarcodeFormatUPCA:
            return "UPC_A"
        case kBarcodeFormatUPCE:
            return "UPC_E"
        case kBarcodeFormatUPCEANExtension:
            return "UPC_EAN_EXTENSION"
        default:
            return "other"
        }
    }
}

extension ZXResultPoint {
    func pointArray() -> [Double] {
        return [Double(x), Double(y)]
    }
}
