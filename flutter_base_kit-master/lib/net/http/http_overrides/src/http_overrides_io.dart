import 'dart:io';

import 'package:flutter_base_kit/common/api_proxy.dart';

class OHttpOverrides extends HttpOverrides {
  static set global(HttpOverrides? overrides) {
    HttpOverrides.global = overrides;
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..findProxy = _findProxy
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }

  String _findProxy(Uri url) {
    // 如果有自定义拦截器, 并且返回非 null 值, 则使用拦截器
    if (ApiProxy.fkHttpOverrides?.findProxy(url) != null) {
      return ApiProxy.fkHttpOverrides!.findProxy(url)!;
    }
    if (ApiProxy.apiProxy != null) {
      return 'PROXY ${ApiProxy.apiProxy}';
    }
    return 'DIRECT';
  }
}
