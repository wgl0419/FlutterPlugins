part of bk_sentry;

class SentryDioInterceptor extends Interceptor {
  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    NeSentry.addTag('dio.err', err.type.name);
    NeSentry.addTag('dio.url', err.requestOptions.uri.toString());
    Sentry.addBreadcrumb(Breadcrumb.http(
      url: err.requestOptions.uri,
      method: err.requestOptions.method,
      reason: '[${err.type.name}] ${err.response?.statusMessage}',
      level: SentryLevel.error,
      statusCode: err.response?.statusCode,
    ));
    err.stackTrace = StackTrace.fromString('SentryDioInterceptor');
    await NeSentry.exception(err);
    super.onError(err, handler);
  }
}

extension DioErrorTypeE on DioErrorType {
  String get name {
    return toString().replaceAll('DioErrorType.', '').toUpperCase();
  }
}
