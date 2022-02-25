import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

abstract class EventTracking {
  /// 事件ID, 非必须, 用于调试
  String eventId = Uuid().v1().replaceAll('-', '');

  /// 事件名称, 非必须, 用于调试
  late String name;
  late String appId;
  late String appSecret;

  /// 事件编号, 必须
  late String eventCode;

  /// 页面编号, 必须
  late String pageCode;

  /// 事件类型, 必须
  late int eventType;

  /// 机器号, 必须
  late String machineId;

  /// 用户ID, 必须
  late String uid;

  /// 网络类型
  late int network;

  /// api 版本号
  String get apiVersion => '1.0';

  /// 平台类型
  int osType = Platform.isAndroid ? 1 : 2;

  EventTracking.private(
      {required this.appId,
      required this.appSecret,
      required this.machineId,
      required this.uid,
      required this.network});

  @mustCallSuper
  Map<String, dynamic> toMap() {
    return {
      'appId': appId,
      'eventCode': eventCode,
      'pageCode': pageCode,
      'eventType': eventType,
      'machineId': machineId,
      'uid': uid,
      'network': network,
      'apiVersion': apiVersion,
      'osType': osType,
    };
  }
}

/// 启动事件
class BootEvent extends EventTracking {
  @override
  String get name => '启动事件';

  @override
  String get pageCode => 'App_Global';

  @override
  int get eventType => 2;

  /// 启动类型
  late int startType;

  /// 启动完成时间
  late String startFinishiTime;

  /// 启动IP
  late String startIp;

  late String cpuUsage;
  late String appCpuUsage;
  late String memoryUsage;
  late String appMemoryUsage;
  late String appMemorySize;
  late String startElapsedTime;

  /// 初始化
  BootEvent(
      {required String appId,
      required String appSecret,
      required String machineId,
      required String uid,
      required int network,
      required this.startFinishiTime,
      required this.startIp,
      required this.cpuUsage,
      required this.appCpuUsage,
      required this.memoryUsage,
      required this.appMemoryUsage,
      required this.appMemorySize,
      required this.startElapsedTime})
      : super.private(appId: appId, appSecret: appSecret, machineId: machineId, uid: uid, network: network);

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = super.toMap();
    map['startType'] = startType;
    map['startFinishiTime'] = startFinishiTime;
    map['startIp'] = startIp;
    map['cpuUsage'] = cpuUsage;
    map['appCpuUsage'] = appCpuUsage;
    map['memoryUsage'] = memoryUsage;
    map['appMemoryUsage'] = appMemoryUsage;
    map['appMemorySize'] = appMemorySize;
    map['startElapsedTime'] = startElapsedTime;
    return map;
  }
}

/// 装机事件
class InstalledEvent extends EventTracking {
  @override
  String get name => '装机事件';

  @override
  String get pageCode => 'App_Global';

  @override
  int get eventType => 1;

  /// 启动类型
  // late int startType;

  /// 启动完成时间
  late String startFinishiTime;

  /// 启动IP
  late String startIp;

  late String cpuUsage;
  late String appCpuUsage;
  late String memoryUsage;
  late String appMemoryUsage;
  late String appMemorySize;
  late String startElapsedTime;

  /// 初始化
  InstalledEvent(
      {required String appId,
      required String appSecret,
      required String machineId,
      required String uid,
      required int network,
      required this.startFinishiTime,
      required this.startIp,
      required this.cpuUsage,
      required this.appCpuUsage,
      required this.memoryUsage,
      required this.appMemoryUsage,
      required this.appMemorySize,
      required this.startElapsedTime})
      : super.private(appId: appId, appSecret: appSecret, machineId: machineId, uid: uid, network: network);

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = super.toMap();
    // map['startType'] = startType;
    map['startFinishiTime'] = startFinishiTime;
    map['startIp'] = startIp;
    map['cpuUsage'] = cpuUsage;
    map['appCpuUsage'] = appCpuUsage;
    map['memoryUsage'] = memoryUsage;
    map['appMemoryUsage'] = appMemoryUsage;
    map['appMemorySize'] = appMemorySize;
    map['startElapsedTime'] = startElapsedTime;
    return map;
  }
}

class PageEvent extends EventTracking {
  @override
  String get name => '页面加载事件';

  @override
  String pageCode = '';

  @override
  int eventType = 4;

  late String operationTime;
  late int usageTime;
  late String loadType;
  late String operationItems;
  late String eventDescription;

  // late String cpuUsage;
  // late String appCpuUsage;
  // late String memoryUsage;
  // late String appMemoryUsage;
  // late String appMemorySize;

  /// 初始化
  PageEvent(
      {required String appId,
      required String appSecret,
      required String machineId,
      required String uid,
      required int network,
      // required this.cpuUsage,
      // required this.appCpuUsage,
      // required this.memoryUsage,
      // required this.appMemoryUsage,
      // required this.appMemorySize,
      required this.pageCode,
      required this.operationTime,
      required this.usageTime,
      required this.loadType,
      required this.operationItems,
      required this.eventDescription})
      : super.private(appId: appId, appSecret: appSecret, machineId: machineId, uid: uid, network: network);

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = super.toMap();
    map['pageCode'] = pageCode;
    map['operationTime'] = operationTime;
    map['usageTime'] = usageTime;
    map['loadType'] = loadType;
    map['operationItems'] = operationItems;
    map['eventDescription'] = eventDescription;
    // map['cpuUsage'] = cpuUsage;
    // map['appCpuUsage'] = appCpuUsage;
    // map['memoryUsage'] = memoryUsage;
    // map['appMemoryUsage'] = appMemoryUsage;
    // map['appMemorySize'] = appMemorySize;
    return map;
  }
}
