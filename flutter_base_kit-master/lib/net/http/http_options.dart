part of http;

/// 请求方法枚举
enum Method { get, post, put, patch, delete, head }

/// 请求类型枚举
enum ContentType { json, formData }

extension MethodExtension on Method {
  String get value => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD'][index];
}

extension ContentTypeExtension on ContentType {
  String get value => [
        Headers.jsonContentType,
        '${Headers.formUrlEncodedContentType}; charset=utf-8'
      ][index];
}
