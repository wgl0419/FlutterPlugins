import 'package:flutter/foundation.dart';

class DeviceUtils {
  DeviceUtils._();
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  static bool get isIos => defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isMobile => isAndroid || isIos;
}
