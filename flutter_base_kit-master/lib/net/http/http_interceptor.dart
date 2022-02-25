import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_base_kit/flutter_base_kit.dart';

class HttpInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!kIsWeb) {
      final Map<String, dynamic> headers = options.headers;
      final userAgent = await FkUserAgent.getPropertyAsync('userAgent') as String;
      headers['user-agent'] = userAgent.toString();
      options.headers = headers;
    }
    super.onRequest(options, handler);
  }
}
