import 'package:flutter_base_kit/utils/storage_utils.dart';

import 'constant.dart';

/// API环境变量类型
///
enum AppEnvironments {
  /// 开发环境
  dev,

  /// 测试环境
  test,

  /// 预发布环境
  pre,

  /// 生产环境
  prod,

  /// 自定义环境
  custom
}

extension ApiEnvTypeExtension on AppEnvironments {
  String get name => ['dev', 'test', 'pre', 'prod', 'custom'][index];
  String get value => ['开发环境', '测试环境', '预发布环境', '生产环境', '自定义环境'][index];
}

/// API环境变量
///
class AppEnv {
  /// 默认环境
  static AppEnvironments _defaultEnv = AppEnvironments.dev;

  static set defaultEnv(AppEnvironments value) {
    _defaultEnv = value;
  }

  static late AppEnvironments _type;

  /// 获取当前的环境变量
  static AppEnvironments currentEnv() {
    final int? index = StorageUtils.sp.read<int>(Constant.appEnvTypeCacheKey, null);
    _type = index == null ? _defaultEnv : AppEnvironments.values[index];
    return _type;
  }

  /// 更改环境变量
  /// [type] 环境变量 [ApiEnvType]
  static Future<bool>? changeEnv(AppEnvironments type) {
    _type = type;
    return StorageUtils.sp.write(Constant.appEnvTypeCacheKey, type.index);
  }

  /// 重置环境变量
  /// 默认为 [ApiEnvType.dev]
  static Future<bool>? resetEnv() {
    _type = _defaultEnv;
    return StorageUtils.sp.write(Constant.appEnvTypeCacheKey, _defaultEnv.index);
  }
}
