//
//  AimoFaceUtils.h
//  flutter_aimall_face_recognition
//
//  Created by huke on 2021/1/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AimoFaceUtils : NSObject

// 保存图片到临时文件夹
+ (NSString *) saveImageToTemporaryDic:(UIImage *)image;

// 获取缓存目录( cache/face_cache_dir)
+ (NSString *) getCacheDir;

// 清除临时缓存文件
+ (void) cleanCacheData;

@end

NS_ASSUME_NONNULL_END
