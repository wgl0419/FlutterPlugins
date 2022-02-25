import 'package:example/pages/home.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    /// 启动页
    GetPage<dynamic>(
      name: Routes.HOME,
      page: () => const MyHomePage(),
      participatesInRootNavigator: true,
      preventDuplicates: true,
      transition: Transition.fade,
    )
  ];
}
