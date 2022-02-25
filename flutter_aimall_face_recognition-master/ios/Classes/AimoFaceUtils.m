//
//  AimoFaceUtils.m
//  flutter_aimall_face_recognition
//
//  Created by huke on 2021/1/7.
//

#import "AimoFaceUtils.h"
#import "ImageUtils.h"

@implementation AimoFaceUtils


+ (NSString *) saveImageToTemporaryDic:(UIImage *)image {
  NSString *imageSavePath = [self getCacheDir];
  NSString *imageFullPath = [NSString stringWithFormat:@"%@/%@.png", imageSavePath, [self uuidString]];
  NSFileManager *fm = [NSFileManager defaultManager];
  BOOL isDir;
  if (![fm fileExistsAtPath:imageSavePath isDirectory:&isDir]) {
    [fm createDirectoryAtPath:imageSavePath withIntermediateDirectories:YES attributes:nil error:nil];
  }
  NSData *data = UIImageJPEGRepresentation([ImageUtils compressImageSize:image toByte:6000], 0.8);
  [fm createFileAtPath:imageFullPath contents:data attributes:nil];
  return imageFullPath;
}

+ (NSString *)uuidString {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

+ (void)cleanCacheData {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *imageSavePath = [self getCacheDir];
    
    if ([fileManager fileExistsAtPath:imageSavePath]) {
        [fileManager removeItemAtPath:imageSavePath error:nil];
    }
}

+ (NSString *) getCacheDir {
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *imageSavePath = [NSString stringWithFormat:@"%@%@", tmpDirectory, @"face_cache_dir"];
    return imageSavePath;
}

@end
