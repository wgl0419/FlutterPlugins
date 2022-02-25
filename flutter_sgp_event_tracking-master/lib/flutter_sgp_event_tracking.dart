import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_udid/flutter_device_udid.dart';
import 'package:flutter_sgp_event_tracking/device_info.dart';
import 'package:flutter_sgp_event_tracking/event.dart';
import 'package:flutter_sgp_event_tracking/event_service.dart';
import 'package:flutter_sgp_event_tracking/event_utils.dart';

import 'event.dart';

class FlutterSgpEventTracking {
  static late String _appId;
  static late String _appSecret;
  static late String _apiHost;
  static late String _deviceId;
  static late int _network;
  static String _userId = '';
  static bool sdkInitStatus = false;

  static const MethodChannel _channel = const MethodChannel('flutter_sgp_event_tracking');

  static String get appId => _appId;

  static String get appSecret => _appSecret;

  static String get apiHost => _apiHost;

  // 初始化
  static void init({required String appId, required String appSecret, required String apiHost}) async {
    if (sdkInitStatus) {
      throw Exception('请不要重复调用初始化!');
    }
    sdkInitStatus = true;
    _appId = appId;
    _appSecret = appSecret;
    _apiHost = apiHost;
    _deviceId = await FlutterDeviceUdid.udid;
    initNetwork();
  }

  /// 设置用户信息
  static void setUserId(String userId) {
    _userId = userId;
  }

  /// 初始化并监听网络情况
  static void initNetwork() async {
    void setNetworkInfo(ConnectivityResult connectivityResult) {
      if (connectivityResult == ConnectivityResult.mobile) {
        _network = 4;
      } else if (connectivityResult == ConnectivityResult.wifi) {
        _network = 3;
      }
    }

    final connectivityResult = await (Connectivity().checkConnectivity());
    setNetworkInfo(connectivityResult);
    Connectivity().onConnectivityChanged.listen(setNetworkInfo);
  }

  /// 获取设备信息
  static Future<DeviceInfo> get getDeviceInfo async {
    return DeviceInfo.fromMap(
      (await _channel.invokeMethod('getDeviceInfo')).cast<String, dynamic>(),
    );
  }

  /// 获取系统版本号
  static Future<String> get systemVersion async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String systemVersion = '';
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      systemVersion = iosDeviceInfo.systemVersion ?? '';
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      systemVersion = androidDeviceInfo.version.sdkInt.toString();
    }
    return systemVersion;
  }

  /// 发送事件
  static Future<void> event(EventTracking event) async {
    event
      ..appId = _appId
      ..appSecret = _appSecret
      ..machineId = _deviceId
      ..uid = _userId
      ..network = _network;
    EventService().addEvent(event);
  }

  /// 操作事件
  ///
  /// [pageCode] 页面编码
  /// [loadType] 调用方式
  /// [operatingItems] 操作内容
  /// [eventDescription] 操作描述
  static Future<void> operateEvent(
      {required String eventCode,
      required String pageCode,
      String? loadType,
      String? operationItems,
      String? eventDescription}) async {
    PageEvent event = PageEvent(
        appId: _appId,
        appSecret: _appSecret,
        machineId: _deviceId,
        uid: _userId,
        network: _network,
        usageTime: 1,
        pageCode: pageCode,
        loadType: loadType ?? '',
        operationItems: operationItems ?? '',
        eventDescription: eventDescription ?? '',
        operationTime: EventUtils.currentDateTime);
    event.eventCode = eventCode;
    event.eventType = 6; // 操作事件
    EventService().addEvent(event);
  }

  /// 页面加载事件
  ///
  /// [pageCode] 页面编码
  /// [loadType] 调用方式
  /// [operatingItems] 操作内容
  /// [eventDescription] 操作描述
  static Future<void> pageEvent(
      {required String eventCode,
      required String pageCode,
      String? loadType,
      String? operationItems,
      String? eventDescription}) async {
    PageEvent event = PageEvent(
        appId: _appId,
        appSecret: _appSecret,
        machineId: _deviceId,
        uid: _userId,
        network: _network,
        usageTime: 1,
        pageCode: pageCode,
        loadType: loadType ?? '',
        operationItems: operationItems ?? '',
        eventDescription: eventDescription ?? '',
        operationTime: EventUtils.currentDateTime);
    event.eventCode = eventCode;
    EventService().addEvent(event);
  }

  /// 热启动事件
  static Future<void> hotBotEvent() async {
    BootEvent event = await _bootEvent;
    event
      ..eventCode = "hotBoot"
      ..startType = 2;
    EventService().addEvent(event);
  }

  /// 冷启动事件
  static Future<void> coldBotEvent() async {
    BootEvent event = await _bootEvent;
    event
      ..eventCode = "coldBoot"
      ..startType = 1;
    EventService().addEvent(event);
  }

  /// 装机事件
  static Future<void> installEvent() async {
    InstalledEvent event = await _installedEvent;
    event..eventCode = "install";
    EventService().addEvent(event);
  }

  static Future<BootEvent> get _bootEvent async {
    DeviceInfo deviceInfo = await getDeviceInfo;
    return BootEvent(
        appId: _appId,
        appSecret: _appSecret,
        machineId: _deviceId,
        uid: _userId,
        network: _network,
        startFinishiTime: EventUtils.currentDateTime,
        startIp: '1.1.1.1',
        cpuUsage: deviceInfo.cpuUsage?.toStringAsFixed(2) ?? '0',
        appCpuUsage: deviceInfo.appCPUUsage?.toStringAsFixed(2) ?? '0',
        memoryUsage: (((deviceInfo.memoryUsed ?? 0) / (deviceInfo.memoryTotal ?? 1))).toStringAsFixed(2),
        appMemoryUsage: ((deviceInfo.appUsedMemory ?? 0) / 1024).toStringAsFixed(2),
        appMemorySize: ((deviceInfo.memoryTotal ?? 0) / 1024).toStringAsFixed(2),
        startElapsedTime: '0');
  }

  static Future<InstalledEvent> get _installedEvent async {
    DeviceInfo deviceInfo = await getDeviceInfo;
    return InstalledEvent(
        appId: _appId,
        appSecret: _appSecret,
        machineId: _deviceId,
        uid: _userId,
        network: _network,
        startFinishiTime: EventUtils.currentDateTime,
        startIp: '1.1.1.1',
        cpuUsage: deviceInfo.cpuUsage?.toStringAsFixed(2) ?? '0',
        appCpuUsage: deviceInfo.appCPUUsage?.toStringAsFixed(2) ?? '0',
        memoryUsage: (((deviceInfo.memoryUsed ?? 0) / (deviceInfo.memoryTotal ?? 1))).toStringAsFixed(2),
        appMemoryUsage: ((deviceInfo.appUsedMemory ?? 0) / 1024).toStringAsFixed(2),
        appMemorySize: ((deviceInfo.memoryTotal ?? 0) / 1024).toStringAsFixed(2),
        startElapsedTime: '0');
  }
}
