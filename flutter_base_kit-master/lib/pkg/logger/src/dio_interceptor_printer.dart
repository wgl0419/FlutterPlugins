part of bk_logger;

int _requestIndex = 0;

mixin DioLogs implements LoggyType {
  @override
  Loggy<DioLogs> get loggy => Loggy<DioLogs>('REQUEST');
}

class LoggyDioInterceptor extends Interceptor with DioLogs {
  LoggyDioInterceptor({
    this.requestHeader = false,
    this.requestBody = false,
    this.responseHeader = false,
    this.responseBody = true,
    this.error = true,
    this.maxWidth = 90,
    this.requestLevel,
    this.responseLevel,
    this.errorLevel,
  });

  final LogLevel? requestLevel;
  final LogLevel? responseLevel;
  final LogLevel? errorLevel;

  /// Print request header [Options.headers]
  final bool requestHeader;

  /// Print request data [Options.data]
  final bool requestBody;

  /// Print [Response.data]
  final bool responseBody;

  /// Print [Response.headers]
  final bool responseHeader;

  /// Print error message
  final bool error;

  /// Width size per logPrint
  final int maxWidth;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _requestIndex++;
    options.extra.addAll(
        {'requestIdx': _requestIndex.toString().padLeft(3, '0'), 'requestTime': DateTime.now().millisecondsSinceEpoch});
    _printRequestHeader(options);
    if (requestHeader) {
      _prettyPrintObject(options.queryParameters, header: 'Query Parameters');
      final requestHeaders = <String, dynamic>{};
      requestHeaders.addAll(options.headers);
      requestHeaders['contentType'] = options.contentType?.toString();
      requestHeaders['responseType'] = options.responseType.toString();
      requestHeaders['followRedirects'] = options.followRedirects;
      requestHeaders['connectTimeout'] = options.connectTimeout;
      requestHeaders['receiveTimeout'] = options.receiveTimeout;

      _prettyPrintObject(requestHeaders, header: 'Headers');
      _prettyPrintObject(options.extra, header: 'Extras');
    }
    if (requestBody && options.method != 'GET') {
      final dynamic data = options.data;
      if (data != null) {
        if (data is FormData) {
          final formDataMap = <String, dynamic>{}
            ..addEntries(data.fields)
            ..addEntries(data.files);
          _prettyPrintObject(formDataMap, header: 'Form data | ${data.boundary}');
        } else {
          _prettyPrintObject(data, header: 'Body');
        }
      }
    }

    _commit(requestLevel ?? LogLevel.info);
    super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (error) {
      if (err.type == DioErrorType.response) {
        logPrint(
            '<<< DioError │ ${err.requestOptions.method} │ ${err.response?.statusCode} ${err.response?.statusMessage} │ ${err.requestOptions.uri.toString()}');
        if (err.response != null && err.response?.data != null) {
          _prettyPrintObject(err.response?.data, header: 'DioError │ ${err.type}');
        }
      } else {
        logPrint('<<< DioError (No response) │ ${err.requestOptions.method} │ ${err.requestOptions.uri.toString()}');
        logPrint('╔ ERROR');
        logPrint('║  ${err.message.replaceAll('\n', '\n║  ')}');
        _printLine(pre: '╚');
      }
    }
    _commit(errorLevel ?? LogLevel.error);
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _printResponseHeader(response);
    if (responseHeader) {
      _prettyPrintObject(response.headers, header: 'Headers');
    }

    if (responseBody) {
      _printResponse(response);
    }

    _commit(responseLevel ?? LogLevel.info);
    super.onResponse(response, handler);
  }

  void _printResponse(Response response) {
    final dynamic data = response.data;

    if (data != null) {
      _prettyPrintObject(data, header: 'Body');
    }
  }

  void _prettyPrintObject(dynamic data, {String? header}) {
    String _value;

    try {
      final dynamic object = const JsonDecoder().convert(data.toString());
      const json = JsonEncoder.withIndent('  ');
      _value = '║  ${json.convert(object).replaceAll('\n', '\n║  ')}';
    } catch (e) {
      _value = '║  ${data.toString().replaceAll('\n', '\n║  ')}';
    }

    logPrint('╔  $header');
    logPrint('║');
    logPrint(_value);
    logPrint('║');
    _printLine(pre: '╚');
  }

  void _printResponseHeader(Response response) {
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method;
    final requestTime = response.requestOptions.extra['requestTime'];
    final requestIdx = response.requestOptions.extra['requestIdx'];
    final times = DateTime.now().millisecondsSinceEpoch - requestTime;
    logPrint(
        '#$requestIdx 👈<<< Response │ $method │ ${response.statusCode} ${response.statusMessage} | $times ms │ ${uri.toString()}');
  }

  void _printRequestHeader(RequestOptions options) {
    final uri = options.uri;
    final method = options.method;
    final requestIdx = options.extra['requestIdx'];
    logPrint('#$requestIdx 👉>>> Request │ $method │ ${uri.toString()}');
  }

  void _printLine({String pre = '', String suf = '╝'}) => logPrint(
        '$pre${'═' * maxWidth}$suf',
      );

  final StringBuffer _value = StringBuffer();

  void logPrint(String value) {
    if (_value.isEmpty) {
      _value.write(value);
    } else {
      _value.write('\n$value');
    }
  }

  void _commit(LogLevel level) {
    if (level.priority >= LogLevel.error.priority) {
      final _valueError = _value.toString();
      final _errorTitle = _valueError.substring(0, _valueError.indexOf('\n'));
      final _errorBody = _valueError.substring(_errorTitle.length);
      loggy.log(level, _errorTitle, _errorBody);
    } else {
      loggy.log(level, _value.toString());
    }
    _value.clear();
  }
}
