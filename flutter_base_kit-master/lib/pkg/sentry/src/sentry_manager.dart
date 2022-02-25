part of bk_sentry;

class SentryManager {
  static bool isInit = false;

  static SentryNavigatorObserver navigatorObserver = SentryNavigatorObserver();

  /// 初始化 Sentry
  ///
  /// [sentryDSN] sentry 地址
  static Future<void> init(String sentryDSN) async {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDSN;
        options.useFlutterBreadcrumbTracking();
        // options.useNativeBreadcrumbTracking();
        // 注入当前的Api环境
        options.environment = AppEnv.currentEnv().name;
        // 是否打开debug模式
        options.debug = kDebugMode;

        /// 钩子
        options.beforeSend = _beforeSend;
        options.beforeBreadcrumb = _beforeBreadcrumb;
      },
      // appRunner: () => runApp(app),
    );
    isInit = true;
  }

  /// 注入 app 扩展信息
  ///
  /// [info] 扩展信息 [SentryAppExtInfo]
  static Future<void> injectAppInfo(SentryAppExtInfo info) async {
    NeSentry.addTag('commitId', info.commitId);
    NeSentry.addTag('buildTime', info.buildTime);
    NeSentry.addTag('channelName', info.channelName);
    NeSentry.addTag('channelVersion', info.channelVersion);
    NeSentry.addTag('deviceId', info.deviceId);
  }

  /// 设置日志级别
  static void setUpLevel(SentryLevel level) {
    if (isInit) {
      Sentry.configureScope((scope) => scope.level = level);
    }
  }

  static SentryEvent _beforeSend(SentryEvent event, {dynamic hint}) {
    if (event.exceptions != null && event.exceptions!.isNotEmpty) {
      int index = 0;
      for (var exception in event.exceptions!) {
        final frames = _handleStackFrame(exception.stackTrace?.frames.toList());
        if (frames == null || frames.isEmpty) {
          continue;
        }
        final stackTrace = SentryStackTrace(frames: frames);
        event.exceptions![index] = exception.copyWith(stackTrace: stackTrace);
        index++;
      }
    }

    if (event.threads != null && event.threads!.isNotEmpty) {
      int index = 0;
      for (SentryThread thread in event.threads!) {
        final frames = _handleStackFrame(thread.stacktrace?.frames.toList());
        if (frames == null || frames.isEmpty) {
          continue;
        }
        Map<String, String>? registers;
        try {
          registers = thread.stacktrace?.registers;
          // ignore: empty_catches
        } catch (e) {}
        final stackTrace = SentryStackTrace(frames: frames, registers: registers);
        event.threads![index] = thread.copyWith(stacktrace: stackTrace);
        index++;
      }
    }

    return event;
  }

  static List<SentryStackFrame>? _handleStackFrame(List<SentryStackFrame>? frames) {
    /// 移除官方库
    frames?.removeWhere((fms) => fms.inApp == null || !fms.inApp!);

    /// 移除 utils
    frames?.removeWhere((fms) => fms.package == 'flutter_base_kit' && fms.fileName == 'sentry.dart');
    return frames;
  }

  static Breadcrumb? _beforeBreadcrumb(Breadcrumb? breadcrumb, {dynamic hint}) {
    if (['device.screen', 'device.event'].contains(breadcrumb?.category)) {
      return null;
    }
    return breadcrumb;
  }
}

class SentryAppExtInfo {
  final String commitId;
  final String buildTime;
  final String channelName;
  final String channelVersion;
  final String deviceId;

  const SentryAppExtInfo(
      {required this.deviceId,
      required this.commitId,
      required this.buildTime,
      required this.channelName,
      required this.channelVersion});
}
