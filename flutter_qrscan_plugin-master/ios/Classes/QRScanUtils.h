//
//  QRScanUtils.h
//  flutter_qrscan_plugin
//
//  Created by SimMan on 2021/10/25.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <CoreMotion/CoreMotion.h>
#import <libkern/OSAtomic.h>

NS_ASSUME_NONNULL_BEGIN

@interface QRScanUtils : NSObject

+ (CVPixelBufferRef)convertYUVImageToBGRA:(CVPixelBufferRef)pixelBuffer previewSize:(CGSize)previewSize;
+ (UIImage *)scaledImage:(UIImage *)image
                maxWidth:(NSNumber *)maxWidth
               maxHeight:(NSNumber *)maxHeight;
@end

NS_ASSUME_NONNULL_END
