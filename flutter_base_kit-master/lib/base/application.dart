import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base_kit/pkg/pkg.dart';
import 'package:flutter_base_kit/pkg/sentry/ne_sentry.dart';
import 'package:flutter_base_kit/utils/app_helper.dart';
import 'package:flutter_base_kit/utils/storage_utils.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

/// 运行应用
///
/// [appName] 应用名称
/// [home] 应用主页-一般由启动页接管
/// [providers] 全局Provider
/// [localeAssetPath] 语言包路径
/// [initRoutes] 路由初始化 Routes.initRoutes();
/// [beforeRunApp] 在runApp前, 初始化其他数据
/// [afterRunApp] 在runApp后, 初始化其他数据
/// [designSize] 设计稿尺寸, 默认为 750x1624 iPhoneX
/// [showPerformanceOverlay] 显示性能标签
/// [debugShowCheckedModeBanner] 去除右上角debug的标签
/// [checkerboardOffscreenLayers] 覆盖层性能棋盘格光栅缓存图像
/// [showSemanticsDebugger] 显示语义视图
/// [checkerboardRasterCacheImages] 检查离屏渲染
/// [sentryDSN] sentry dsn
Future<void> runMainApp(
    {String? appName,
    Translations? translations,
    Locale? locale,
    Locale? fallbackLocale,
    Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates = const [
      GlobalCupertinoLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    Iterable<Locale> supportedLocales = const <Locale>[Locale('en', 'US')],
    Bindings? initialBinding,
    List<GetPage>? getPages,
    String? initialRoute,
    AsyncCallback? beforeRunApp,
    AsyncCallback? afterRunApp,
    ThemeData? theme,
    ThemeData? darkTheme,
    ThemeMode themeMode = ThemeMode.light,
    Size designSize = const Size(750, 1624),
    bool showPerformanceOverlay = false,
    bool debugShowCheckedModeBanner = false,
    bool checkerboardOffscreenLayers = false,
    bool showSemanticsDebugger = false,
    bool checkerboardRasterCacheImages = false,
    String? sentryDSN,
    List<NavigatorObserver>? navigatorObservers,
    RouteFactory? onUnknownRoute,
    Transition? defaultTransition,
    Duration? transitionDuration,
    CustomTransition? customTransition}) async {
  /// 初始化 WidgetsBinding 的全局单例
  WidgetsFlutterBinding.ensureInitialized();

  /// 捕获并上报 Flutter 异常
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (kDebugMode == true) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    }
  };

  /// 捕获并上报 Dart 异常
  runZonedGuarded(() async {
    /// 日志初始化
    Loggy.initLoggy(
        logPrinter: const FlutterDeveloperPrinter(),
        logOptions: const LogOptions(kReleaseMode ? LogLevel.error : LogLevel.all,
            stackTraceLevel: LogLevel.error, includeCallerInfo: true),
        filters: [LoggerFilter()]);

    /// sp初始化
    logger.d('初始化Storage');
    await StorageUtils.init();

    /// 记录应用第一次启动时间
    await AppHelper.setFirstStartupTime();

    if (beforeRunApp != null) {
      logger.d('调用beforeRunApp');
      await beforeRunApp();
    }

    /// 初始化 Sentry
    if (!kDebugMode && sentryDSN != null) {
      await SentryManager.init(sentryDSN);
    }

    /// 初始化Toast
    final botToastBuilder = BotToastInit();
    runApp(GetMaterialApp(
      title: appName ?? '',
      translations: translations,
      locale: locale,
      fallbackLocale: fallbackLocale,
      supportedLocales: supportedLocales,
      localizationsDelegates: localizationsDelegates,
      showPerformanceOverlay: showPerformanceOverlay,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      checkerboardOffscreenLayers: checkerboardOffscreenLayers,
      showSemanticsDebugger: showSemanticsDebugger,
      checkerboardRasterCacheImages: checkerboardRasterCacheImages,
      initialBinding: initialBinding,
      getPages: getPages,
      initialRoute: initialRoute,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      navigatorObservers: navigatorObservers == null
          ? <NavigatorObserver>[SentryManager.navigatorObserver, BotToastNavigatorObserver()]
          : (<NavigatorObserver>[SentryManager.navigatorObserver, BotToastNavigatorObserver(), ...navigatorObservers]),
      onUnknownRoute: onUnknownRoute,
      defaultTransition: defaultTransition,
      transitionDuration: transitionDuration,
      customTransition: customTransition,
      builder: (context, child) {
        return ScreenUtilInit(
          designSize: designSize,
          builder: () {
            /// 初始化 toast
            return botToastBuilder(
                context,

                /// 保证文字大小不受手机系统设置影响 https://www.kikt.top/posts/flutter/layout/dynamic-text/
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  // 或者 MediaQueryData.fromWindow(WidgetsBinding.instance.window).copyWith(textScaleFactor: 1.0),
                  child: child!,
                ));
          },
        );
      },
      logWriterCallback: _getxLogWriter,
    ));

    NeSentry.addBreadcrumb('Application started');

    if (afterRunApp != null) {
      logger.d('调用afterRunApp');
      await afterRunApp();
    }
  }, (Object error, StackTrace stack) async {
    /// 上报异常到 Sentry
    if (kDebugMode) {
      logger.e('appError', stackTrace: stack);
    } else {
      await NeSentry.exception(error, stackTrace: stack);
    }
  });
}

void _getxLogWriter(String text, {bool isError = false}) {
  if (Get.isLogEnable) {
    if (isError) {
      logger.e(text);
    } else {
      logger.d(text);
    }
  }
}
