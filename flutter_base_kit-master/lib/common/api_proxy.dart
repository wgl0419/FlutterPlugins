import 'package:flutter_base_kit/net/http/http_overrides/http_overrides.dart';
import 'package:flutter_base_kit/utils/storage_utils.dart';

import 'constant.dart';

class ApiProxy {
  /// 主机地址
  static String? _host;

  /// 端口号
  static int? _port;

  /// 获取代理信息
  static String get _apiProxy => '$_host:$_port';

  static NeHttpOverrides? fkHttpOverrides;

  /// 设置代理
  static Future<bool?> setProxy(String host, int port) async {
    _host = host;
    _port = port;
    return await StorageUtils.sp.write(Constant.apiProxyCacheKey, _apiProxy);
  }

  /// 获取代理配置
  static String? get apiProxy {
    if (_host != null && _host!.isNotEmpty && _port != null) {
      return _apiProxy;
    }
    final String? proxy = StorageUtils.sp.read<String>(Constant.apiProxyCacheKey);
    if (proxy != null) {
      _host = proxy.split(':').first;
      _port = int.tryParse(proxy.split(':').last);
      return _apiProxy;
    }
    return null;
  }

  /// 重置代理配置
  static Future<void> resetProxy() async {
    _host = null;
    _port = null;
    await StorageUtils.sp.delete(Constant.apiProxyCacheKey);
    OHttpOverrides.global = null;
  }

  static void initApiProxy() {
    OHttpOverrides.global = OHttpOverrides();
  }
}

/// 代理覆盖
abstract class NeHttpOverrides {
  /// 如果返回 null, 则使用默认代理设置
  String? findProxy(Uri url);
}
