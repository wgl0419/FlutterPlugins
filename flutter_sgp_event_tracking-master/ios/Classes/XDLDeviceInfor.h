//
//  XDLDeviceInfor.h
//  XDLogCollection
//
//  Created by coco.zhu on 2021/1/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDLDeviceInfor : NSObject
///设备名称，比如iphone 5s ,iphone 6s
- (NSString *)getDeviceName;

///获取CPU 型号
- (NSString *)getDeviceCUPName;
/// 获取ip
- (NSString *)getIPAddresses;

///CPU使用情况
- (float)getCPUUsage;
///app CPU使用情况
- (double)getAppCPUUsage;

- (int64_t)getMemoryUsed;
- (int64_t)getMemoryTotal;
- (int64_t)getMemoryFree;
- (float)getAppUsedMemory;

///获取app大小
- (int64_t)getAppSize;
///已经使用的磁盘大小
- (int64_t)getUsedDiskSpace;
///未使用的磁盘大小
- (int64_t)getFreeDiskSpace;
///磁盘总空间
- (int64_t)getTotalDiskSpace;



@end

NS_ASSUME_NONNULL_END
