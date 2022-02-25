part of http;

class HttpClient {
  late Dio _dio;

  Dio get dio => _dio;

  /// 自定义解析器
  ResponseTransformer? _responseTransformer;

  /// 默认配置
  final BaseOptions _defaultOptions = BaseOptions(
    connectTimeout: 10000,
    // 10s
    receiveTimeout: 10000,
    // 10s
    sendTimeout: 10000,
    // 10s
    contentType: ContentType.json.value,
    responseType: ResponseType.json,
  );

  HttpClient({BaseOptions? options}) {
    /// 初始化dio
    _dio = Dio(options != null
        ? _defaultOptions.copyWith(
            connectTimeout: options.connectTimeout,
            receiveTimeout: options.receiveTimeout,
            sendTimeout: options.sendTimeout,
            headers: options.headers)
        : _defaultOptions);

    addInterceptors([HttpInterceptor(), SentryDioInterceptor()]);

    /// 设置默认的json transformer
    (_dio.transformer as DefaultTransformer).jsonDecodeCallback = JsonTransformer.decode;
  }

  /// 添加拦截器
  ///
  /// [interceptors] 拦截器
  void addInterceptors(List<Interceptor> interceptors) {
    dio.interceptors.addAll(interceptors);
  }

  void setObjectTransformer(ResponseTransformer responseTransformer) {
    _responseTransformer = responseTransformer;
  }

  Options _checkOptions(String method, Options? options, ContentType? contentType) {
    options ??= Options();
    options.method = method;
    options.responseType = ResponseType.json;
    if (contentType != null) {
      options.contentType = contentType.value;
    }
    return options;
  }

  Future<ResponseModel<T>> request<T>(
    Method method,
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ContentType? contentType,
  }) async {
    final Options ops = _checkOptions(method.value, options, contentType);
    try {
      final Response response = await _dio.request(
        url,
        data: data,
        queryParameters: queryParameters,
        options: ops,
        cancelToken: cancelToken,
      );
      if (_responseTransformer != null) {
        return await _responseTransformer!.onTransform<T>(response.data);
      }
      return ResponseModel(response.statusCode ?? 0, 0, '', 0, response.data);
    } on DioError catch (e) {
      return ResponseModel(e.response?.statusCode ?? 0, -9000, e.message, 0, null);
    } catch (e) {
      return ResponseModel(0, -9500, e.toString(), 0, null);
    }
  }

  Future<ResponseModel<T>> get<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ContentType? contentType,
  }) async {
    return request(Method.get, url,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        contentType: contentType);
  }

  Future<ResponseModel<T>> post<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ContentType? contentType,
  }) async {
    return request(Method.post, url,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        contentType: contentType);
  }
}
