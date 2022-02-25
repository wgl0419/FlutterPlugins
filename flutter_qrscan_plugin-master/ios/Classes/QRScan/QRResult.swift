//
//  QRResult.swift
//  QRScanDemo
//
//  Created by SimMan on 2021/10/25.
//

import Foundation

public class QRResult: NSObject {
    var barcodeFormat: String
    var text: String
    var points: [[Double]]
    
    init(barcodeFormat: String, text: String, points: [[Double]]) {
        self.barcodeFormat = barcodeFormat
        self.text = text
        self.points = points
        super.init()
    }
    
    func toMap() -> [String: Any] {
        return [
            "text": text,
            "barcodeFormat": barcodeFormat,
            "points": points
        ]
    }
}
