import 'package:flutter_dev_tools/pages/api_env_page.dart';
import 'package:flutter_dev_tools/pages/api_proxy_page.dart';
import 'package:flutter_dev_tools/pages/devtools_page.dart';
import 'package:flutter_dev_tools/pages/info_page.dart';
import 'package:flutter_dev_tools/pages/network_page.dart';
import 'package:get/get.dart';

class Routes {
  Routes._();

  static const String devToolsPage = '/devTools';
  static const String infoPage = '/devTools/info';
  static const String sharedPreferencesPage = '/devTools/spPage';
  static const String networkPage = '/devTools/networkPage';
  static const String apiEnvPage = '/devTools/apiEnvPage';
  static const String apiProxyPage = '/devTools/ApiProxyPage';
  static const String sandboxPage = '/devTools/sandboxPage';
  static const String sandboxListPage = '/devTools/sandboxListPage';
  static const String loggyStreamPage = '/devTools/loggyStreamPage';
  static const String h5sdkPage = '/devTools/h5sdkPage';
  static const String scanQrcodePage = '/devTools/scanQrcodePage';
  static const String appListPage = '/devTools/appListPage';
  static const String teambitionPage = '/devTools/teambitionPage';
}

class AppPages {
  AppPages._();

  static final routes = [
    GetPage<dynamic>(
      name: Routes.devToolsPage,
      page: () => const DevToolsPage(),
      participatesInRootNavigator: true,
      preventDuplicates: true,
    ),
    GetPage<dynamic>(
      name: Routes.infoPage,
      page: () => const InfoPage(),
      participatesInRootNavigator: true,
      preventDuplicates: true,
    ),
    GetPage<dynamic>(
      name: Routes.networkPage,
      page: () => const NetworkPage(),
      participatesInRootNavigator: true,
      preventDuplicates: true,
    ),
    GetPage<dynamic>(
      name: Routes.apiEnvPage,
      page: () => const ApiEnvPage(),
      participatesInRootNavigator: true,
      preventDuplicates: true,
    ),
    GetPage<dynamic>(
      name: Routes.apiProxyPage,
      page: () => const ApiProxyPage(),
      participatesInRootNavigator: true,
      preventDuplicates: true,
    ),
  ];
}
