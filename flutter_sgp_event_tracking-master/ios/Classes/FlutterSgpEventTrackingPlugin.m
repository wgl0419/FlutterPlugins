#import "FlutterSgpEventTrackingPlugin.h"
#import "XDLDeviceInfor.h"
@implementation FlutterSgpEventTrackingPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_sgp_event_tracking"
            binaryMessenger:[registrar messenger]];
  FlutterSgpEventTrackingPlugin* instance = [[FlutterSgpEventTrackingPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getDeviceInfo" isEqualToString:call.method]) {
      XDLDeviceInfor *info = [XDLDeviceInfor new];
      result(@{
                @"deviceCUPName": [info getDeviceCUPName],
                @"cpuUsage": [NSNumber numberWithFloat:[info getCPUUsage]],
                @"appCPUUsage": [NSNumber numberWithDouble:[info getAppCPUUsage]],
                @"memoryUsed": [NSNumber numberWithLongLong:[info getMemoryUsed]],
                @"memoryTotal": [NSNumber numberWithLongLong:[info getMemoryTotal]],
                @"memoryFree": [NSNumber numberWithLongLong:[info getMemoryFree]],
                @"appUsedMemory": [NSNumber numberWithFloat:[info getAppUsedMemory]],
                @"appSize": [NSNumber numberWithLongLong:[info getAppSize]],
                @"usedDiskSpace": [NSNumber numberWithLongLong:[info getUsedDiskSpace]],
                @"freeDiskSpace": [NSNumber numberWithLongLong:[info getFreeDiskSpace]],
                @"totalDiskSpace": [NSNumber numberWithLongLong:[info getTotalDiskSpace]]});
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
