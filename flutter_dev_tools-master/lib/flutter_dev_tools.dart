library flutter_dev_tools;

import 'package:flutter_action_sheet/flutter_action_sheet.dart';
import 'package:flutter_base_kit/flutter_base_kit.dart';
import 'package:flutter_dev_tools/data_delegate.dart';
import 'package:flutter_dev_tools/routes/dev_tools_route.dart';
import 'package:get/get.dart';
import 'package:sensors/sensors.dart';

class FlutterDevTools {
  static int _shakeCount = 0;
  static const Duration _duration = Duration(milliseconds: 200);
  static DateTime? _lastTime;
  static bool isShowDebugTools = false;
  static FlutterDevToolsDataDelegate? dataDelegate;

  static void init({FlutterDevToolsDataDelegate? delegate}) {
    dataDelegate = delegate;

    /// 注入dev tools page
    Get.addPages(AppPages.routes);

    /// 监听传感器
    accelerometerEvents.listen((AccelerometerEvent event) {
      /// 部分手机最高20
      int value = 20;
      if (event.x >= value ||
          event.x <= -value ||
          event.y >= value ||
          event.y <= -value ||
          event.z >= value ||
          event.z <= -value) {
        if (_lastTime == null || DateTime.now().difference(_lastTime!) > _duration) {
          _lastTime = DateTime.now();
          _shakeCount++;
        }
      }
      if (_shakeCount >= 2) {
        _shakeCount = 0;

        if (AppEnv.currentEnv() != AppEnvironments.prod) {
          if (!isShowDebugTools) {
            isShowDebugTools = true;
            showQuickTools();
            Future.delayed(const Duration(seconds: 5), () {
              isShowDebugTools = false;
            });
          }
        }
      }
    });
  }

  /// 显示快速工具
  ///
  /// 包含 Teambition、DebugTools
  static void showQuickTools() {
    showActionSheet(
      context: Get.context!,
      enableDrag: false,
      actionSheetBar: const ActionSheetBar('请选择', showAction: false),
      actions: [
        ActionSheetItem('Teambition', onPress: () async {
          Get.back();
          showTeambition();
        }),
        ActionSheetItem('DevTools', onPress: () async {
          Get.back();
          showDebugTools();
        }),
      ],
      bottomAction: const BottomCancelActon('取消'),
    );
  }

  /// 显示调试工具
  static void showDebugTools() {
    Get.toNamed(Routes.devToolsPage);
  }

  /// 显示Teambition
  static void showTeambition() {
    Toast.showError('暂不支持!');
  }
}
