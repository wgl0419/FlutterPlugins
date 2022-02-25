import 'package:dio/dio.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter_sgp_event_tracking/event_utils.dart';

class RequestUtils {
  static RequestUtils? _instance;
  late Dio _dio;

  RequestUtils._internal() {
    _instance = this;
    final options = BaseOptions(
      connectTimeout: 10000,
      receiveTimeout: 5000,
    );
    _dio = Dio(options);
    _dio.interceptors
      ..add(RequestSignInterceptor())
      ..add(LogInterceptor(requestHeader: true, responseBody: true, requestBody: true));
    // (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
    //   client.findProxy = (uri) {
    //     return 'PROXY 192.168.1.39:20001';
    //   };
    //   client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    // };
  }

  factory RequestUtils() => _instance ?? RequestUtils._internal();

  Future<dynamic> get(String url, dynamic params, Map<String, dynamic>? extra) async {
    return _dio.get(url, queryParameters: params, options: Options(extra: extra));
  }

  Future<dynamic> post(String url, dynamic data, Map<String, dynamic>? extra) async {
    return _dio.post(url, data: data, options: Options(extra: extra));
  }
}

class RequestSignInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final headers = options.headers;
    final extra = options.extra;
    final timeStamp = DateTime.now().millisecondsSinceEpoch;
    headers['timestamp'] = timeStamp;
    headers['sign'] = EventUtils.getSign(options.data, extra['appId'], extra['appSecret'], timeStamp);
    final userAgent = await FkUserAgent.getPropertyAsync('userAgent') as String;
    headers['user-agent'] = userAgent.toString();
    options.headers = headers;
    super.onRequest(options, handler);
  }
}
