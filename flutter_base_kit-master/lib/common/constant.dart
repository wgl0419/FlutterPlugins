import 'package:flutter/foundation.dart';

class Constant {
  /// debug开关，上线需要关闭
  /// App运行在Release环境时，inProduction为true；当App运行在Debug和Profile环境时，inProduction为false
  static const bool inProduction = kReleaseMode;

  /// app 主题样式
  static const String theme = 'AppTheme';

  static const String exitAppToastText = 'exit_app_toast_text';

  /// 自定义apiHost缓存key
  static const String customApiUrlConfigCacheKey = 'customApiUrlConfigCacheKey';

  /// app环境缓存key
  static const String appEnvTypeCacheKey = 'appEnvTypeCacheKey';

  /// apiProxy缓存key
  static const String apiProxyCacheKey = 'apiProxyCacheKey';

  /// app 首次启动时间
  static const String firstStartupTimeKey = 'firstStartupTime';

  /// 安全存储密钥key
  static const String secureStorageKey = 'secureStorageKey';
}
