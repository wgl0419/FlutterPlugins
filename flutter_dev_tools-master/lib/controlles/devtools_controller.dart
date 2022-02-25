import 'package:flutter_dev_tools/flutter_dev_tools.dart';
import 'package:get/get.dart';

class DevToolsController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    FlutterDevTools.isShowDebugTools = true;
  }

  @override
  void onClose() {
    FlutterDevTools.isShowDebugTools = false;
    super.onClose();
  }
}
