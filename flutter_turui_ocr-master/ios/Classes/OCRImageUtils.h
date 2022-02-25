//
//  ImageUtils.h
//  AppFaceActionDetector
//
//  Created by huke on 2020/6/16.
//  Copyright © 2020 AIMall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface OCRImageUtils : NSObject

+ (UIImage*)imageFromRGB888:(void*)rawData width:(int)width height:(int)height;
+ (unsigned char *)pixelBRGABytesFromImage:(UIImage *)image;
+ (unsigned char *)pixelBRGABytesFromImageRef:(CGImageRef)imageRef;
+ (UIImage *)getImageResourceForName:(NSString *)name;
+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;
+ (NSString *)encodeToBase64String:(UIImage *)image;
+ (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData;
+(UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;
+ (UIImage *)compressImageSize:(UIImage *)image toByte:(NSUInteger)maxLength;
+ (UIImage *)imageFromRect:(CGRect)rect FromImage:(UIImage *)image;
+ (UIImage *)fixOrientationFromImage:(UIImage *)image;
+ (NSString *) saveImageToTemporaryDic:(UIImage *)image;

@end
