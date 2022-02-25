part of http;

class ResponseModel<T> {
  final int status;

  /// 状态码
  /// [code]
  final int code;

  /// 错误信息
  /// [message] 默认为''
  final String? message;

  /// 数据版本号
  /// [version] 默认为0
  final int? version;

  /// 业务数据
  /// [data] 默认为null
  final T? data;

  const ResponseModel(
      this.status, this.code, this.message, this.version, this.data);

  const ResponseModel.named(
      {this.status = 200,
      this.code = 0,
      this.version,
      this.data,
      this.message});

  @override
  String toString() {
    return 'status: $status, code: $code, message: $message, version: $version, data: $data';
  }
}
