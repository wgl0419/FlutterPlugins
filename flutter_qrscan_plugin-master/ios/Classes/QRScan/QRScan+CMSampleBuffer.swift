//
//  QRScan+CMSampleBuffer.swift
//  QRScanDemo
//
//  Created by SimMan on 2021/10/25.
//
import Foundation
import AVFoundation
import UIKit

extension CMSampleBuffer {
    func brightness() -> CGFloat {
      guard
        let metadataDict = CMCopyDictionaryOfAttachments(allocator: nil, target: self, attachmentMode: kCMAttachmentMode_ShouldPropagate) as? [String: Any],
          let exifMetadata = metadataDict[String(kCGImagePropertyExifDictionary)] as? [String: Any],
          let brightnessValue = exifMetadata[String(kCGImagePropertyExifBrightnessValue)] as? CGFloat
          else { return 0.0 }

      return brightnessValue
    }
    
    /// https://stackoverflow.com/questions/15726761/make-an-uiimage-from-a-cmsamplebuffer
    func image(orientation: UIImage.Orientation = .up, scale: CGFloat = 1.0) -> UIImage? {
        if let buffer = CMSampleBufferGetImageBuffer(self) {
            let ciImage = CIImage(cvPixelBuffer: buffer)

            return UIImage(ciImage: ciImage, scale: scale, orientation: orientation)
        }

        return nil
    }

    func imageWithCGImage(orientation: UIImage.Orientation = .up, scale: CGFloat = 1.0) -> UIImage? {
        if let buffer = CMSampleBufferGetImageBuffer(self) {
            let ciImage = CIImage(cvPixelBuffer: buffer)

            let context = CIContext(options: nil)

            guard let cg = context.createCGImage(ciImage, from: ciImage.extent) else {
                return nil
            }
            
            return UIImage(cgImage: cg, scale: scale, orientation: orientation)
        }

        return nil
    }
}
