import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base_kit/common/common.dart';
import 'package:flutter_base_kit/utils/storage_utils.dart';

class AppHelper {
  AppHelper._();

  /// blocks rotation; sets orientation to: portrait
  static Future<void> portraitModeOnly() {
    return SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
  }

  /// blocks rotation; sets orientation to: landscape
  static Future<void> landscapeModeOnly() {
    return SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );
  }

  /// Enable rotation
  static Future<void> enableRotation() {
    return SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );
  }

  /// Change next focus
  static void nextFocus(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  /// Fullscreen mode
  static Future<void> enableFullscreen() async {
    return SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: <SystemUiOverlay>[]);
  }

  /// Disable fullscreen mode
  static Future<void> disableFullscreen() async {
    return SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  /// 获取app第一次启动时间
  ///
  /// 如果返回null, 则为第一次启动
  static DateTime? firstStartupTime() {
    final time = StorageUtils.sp.read<String>(Constant.firstStartupTimeKey);
    if (time != null) {
      return DateTime.parse(time);
    }
    return null;
  }

  /// 设置app第一次启动时间
  static Future<bool> setFirstStartupTime() async {
    DateTime _dateTime = DateTime.now();
    if (firstStartupTime() == null) {
      return await StorageUtils.sp.write(Constant.firstStartupTimeKey, _dateTime.toIso8601String());
    }
    return false;
  }
}
