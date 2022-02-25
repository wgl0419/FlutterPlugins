# Nebula

Flutter 快速开发框架

## 快速接入

### 1. 引入依赖

```yaml
flutter_base_kit:
    hosted:
      name: flutter_base_kit
      url: https://pub.youzi.dev
    version: <latest_version>
```

### 2. 包装 main.dart

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 显示状态栏、底部按钮栏(因为在启动页的时候进行了隐藏)
  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

  /// 透明状态栏
  if (DeviceUtils.isAndroid) {
    const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  /// 此处设置默认的api环境(初始值为test)
  AppEnv.defaultEnv = AppEnvironments.pre;
  /// 此处设置当前版本使用的链是测试链
  QiRpcService.setChainNet(QiChainNet.TEST_NET);

  /// 执行 RunApp
  await runMainApp(
    appName: 'AITD Coin',
    beforeRunApp: () async {
      AppEnv.changeEnv(AppEnvironments.pre);

      /// 初始化 Url
      await ApiUrls.initApiUrls();

      logger.i('应用运行路径: ${await getApplicationSupportDirectory()}');
    },
    initialBinding: initService(),
    theme: AppTheme.theme,
    darkTheme: AppTheme.darkTheme,
    designSize: const Size(375, 812),
    themeMode: ThemeMode.system,
    translations: I18nTranslations(),
    supportedLocales: SupportedLocales.values,
    locale: Get.locale,
    fallbackLocale: SupportedLocales.zh_CN,
    getPages: AppPages.routes,
    defaultTransition: Transition.cupertino,
    initialRoute: AppPages.routes.first.name,
    localizationsDelegates: const [
      RefreshLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
  );
}
```


## 目录结构

```shell
lib
├── base
│   ├── application.dart
│   ├── base.dart
│   └── base_controller.dart
├── common
│   ├── api_proxy.dart
│   ├── app_env.dart
│   ├── common.dart
│   └── constant.dart
├── flutter_base_kit.dart
├── mixins
│   ├── connectivity
│   └── mixins.dart
├── net
│   ├── http
│   ├── net.dart
│   └── websocket
├── pkg
│   ├── logger
│   ├── pkg.dart
│   └── sentry
├── utils
│   ├── app_helper.dart
│   ├── device_utils.dart
│   ├── encrypt_utils.dart
│   ├── image_utils.dart
│   ├── num_utils.dart
│   ├── random_utils.dart
│   ├── storage_utils.dart
│   └── utils.dart
└── widgets
    ├── after_route_animation.dart
    ├── double_tap_back_exit_app.dart
    ├── load_image.dart
    ├── toast.dart
    └── widgets.dart
```