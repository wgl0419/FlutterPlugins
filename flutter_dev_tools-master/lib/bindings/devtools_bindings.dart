import 'package:flutter_dev_tools/controlles/devtools_controller.dart';
import 'package:get/get.dart';

class DevToolsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DevToolsController());
  }
}
