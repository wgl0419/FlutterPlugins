import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base_kit/flutter_base_kit.dart';

import 'routes/app_pages.dart';
import 'services/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppHelper.portraitModeOnly();

  /// 此处设置默认的api环境(初始值为test)
  AppEnv.defaultEnv = AppEnvironments.pre;

  /// 执行 RunApp
  await runMainApp(
    appName: 'UCore',
    beforeRunApp: () async {
      /// 初始化 Url
      // await ApiUrls.initApiUrls();

      logger.i('应用运行路径: ${await getApplicationSupportDirectory()}');
    },
    afterRunApp: () async {
      /// 显示状态栏、底部按钮栏(因为在启动页的时候进行了隐藏)
      await AppHelper.disableFullscreen();

      /// 透明状态栏
      if (DeviceUtils.isAndroid) {
        const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
        SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
      }
    },
    initialBinding: await initService(),
    designSize: const Size(375, 812),
    themeMode: ThemeMode.system,
    locale: Get.locale,
    getPages: AppPages.routes,
    defaultTransition: Transition.cupertino,
    initialRoute: AppPages.routes.first.name,
    sentryDSN: !kReleaseMode ? 'https://5c1b84aee6484899baea4539b94e17f7@o65500.ingest.sentry.io/6055423' : null,
  );
}
