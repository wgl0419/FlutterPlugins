//
//  QRScanUtils.m
//  flutter_qrscan_plugin
//
//  Created by SimMan on 2021/10/25.
//

#import "QRScanUtils.h"

@implementation QRScanUtils

+ (CVPixelBufferRef)convertYUVImageToBGRA:(CVPixelBufferRef)pixelBuffer previewSize:(CGSize)previewSize {
    
  vImage_Buffer destinationBuffer;
  vImage_Buffer conversionBuffer;
    
    vImageBuffer_Init(&destinationBuffer, previewSize.width, previewSize.height, 32,
                  kvImageNoFlags);
  vImageBuffer_Init(&conversionBuffer, previewSize.width, previewSize.height, 32,
                  kvImageNoFlags);
    
  CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);

  vImage_YpCbCrToARGB infoYpCbCrToARGB;
  vImage_YpCbCrPixelRange pixelRange;
  pixelRange.Yp_bias = 16;
  pixelRange.CbCr_bias = 128;
  pixelRange.YpRangeMax = 235;
  pixelRange.CbCrRangeMax = 240;
  pixelRange.YpMax = 235;
  pixelRange.YpMin = 16;
  pixelRange.CbCrMax = 240;
  pixelRange.CbCrMin = 16;

  vImageConvert_YpCbCrToARGB_GenerateConversion(kvImage_YpCbCrToARGBMatrix_ITU_R_601_4, &pixelRange,
                                                &infoYpCbCrToARGB, kvImage420Yp8_CbCr8,
                                                kvImageARGB8888, kvImageNoFlags);

  vImage_Buffer sourceLumaBuffer;
  sourceLumaBuffer.data = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
  sourceLumaBuffer.height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
  sourceLumaBuffer.width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
  sourceLumaBuffer.rowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);

  vImage_Buffer sourceChromaBuffer;
  sourceChromaBuffer.data = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
  sourceChromaBuffer.height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
  sourceChromaBuffer.width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
  sourceChromaBuffer.rowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);

  vImageConvert_420Yp8_CbCr8ToARGB8888(&sourceLumaBuffer, &sourceChromaBuffer, &destinationBuffer,
                                       &infoYpCbCrToARGB, NULL, 255,
                                       kvImagePrintDiagnosticsToConsole);

  CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
  CVPixelBufferRelease(pixelBuffer);

  const uint8_t map[4] = {3, 2, 1, 0};
  vImagePermuteChannels_ARGB8888(&destinationBuffer, &conversionBuffer, map, kvImageNoFlags);

  CVPixelBufferRef newPixelBuffer = NULL;
  CVPixelBufferCreateWithBytes(NULL, conversionBuffer.width, conversionBuffer.height,
                               kCVPixelFormatType_32BGRA, conversionBuffer.data,
                               conversionBuffer.rowBytes, NULL, NULL, NULL, &newPixelBuffer);

  return newPixelBuffer;
}

+ (UIImage *)scaledImage:(UIImage *)image maxWidth:(NSNumber *)maxWidth maxHeight:(NSNumber *)maxHeight {
    double originalWidth = image.size.width;
    double originalHeight = image.size.height;

    bool hasMaxWidth = maxWidth != (id)[NSNull null];
    bool hasMaxHeight = maxHeight != (id)[NSNull null];

    double width = hasMaxWidth ? MIN([maxWidth doubleValue], originalWidth) : originalWidth;
    double height = hasMaxHeight ? MIN([maxHeight doubleValue], originalHeight) : originalHeight;

    bool shouldDownscaleWidth = hasMaxWidth && [maxWidth doubleValue] < originalWidth;
    bool shouldDownscaleHeight = hasMaxHeight && [maxHeight doubleValue] < originalHeight;
    bool shouldDownscale = shouldDownscaleWidth || shouldDownscaleHeight;

    if (shouldDownscale) {
      double downscaledWidth = floor((height / originalHeight) * originalWidth);
      double downscaledHeight = floor((width / originalWidth) * originalHeight);

      if (width < height) {
        if (!hasMaxWidth) {
          width = downscaledWidth;
        } else {
          height = downscaledHeight;
        }
      } else if (height < width) {
        if (!hasMaxHeight) {
          height = downscaledHeight;
        } else {
          width = downscaledWidth;
        }
      } else {
        if (originalWidth < originalHeight) {
          width = downscaledWidth;
        } else if (originalHeight < originalWidth) {
          height = downscaledHeight;
        }
      }
    }

    // Scaling the image always rotate itself based on the current imageOrientation of the original
    // Image. Set to orientationUp for the orignal image before scaling, so the scaled image doesn't
    // mess up with the pixels.
    UIImage *imageToScale = [UIImage imageWithCGImage:image.CGImage
                                                scale:1
                                          orientation:UIImageOrientationUp];

    // The image orientation is manually set to UIImageOrientationUp which swapped the aspect ratio in
    // some scenarios. For example, when the original image has orientation left, the horizontal
    // pixels should be scaled to `width` and the vertical pixels should be scaled to `height`. After
    // setting the orientation to up, we end up scaling the horizontal pixels to `height` and vertical
    // to `width`. Below swap will solve this issue.
    if ([image imageOrientation] == UIImageOrientationLeft ||
        [image imageOrientation] == UIImageOrientationRight ||
        [image imageOrientation] == UIImageOrientationLeftMirrored ||
        [image imageOrientation] == UIImageOrientationRightMirrored) {
      double temp = width;
      width = height;
      height = temp;
    }

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 1.0);
    [imageToScale drawInRect:CGRectMake(0, 0, width, height)];

    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
