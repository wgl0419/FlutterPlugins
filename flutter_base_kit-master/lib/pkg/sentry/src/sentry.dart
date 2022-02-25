part of bk_sentry;

class NeSentry {
  /// 设置用户信息
  ///
  /// [userId] 用户ID
  /// [userName] 用户名/手机号
  /// [email] 邮箱
  /// [extras] 扩展信息
  static void setUpUser(String userId, {String? userName, String? email, Map<String, dynamic>? extras}) {
    if (!SentryManager.isInit) {
      return;
    }

    Sentry.configureScope(
      (scope) =>
          scope.user = SentryUser(id: userId, username: userName, email: email, ipAddress: '{{auto}}', extras: extras),
    );
  }

  /// 清除用户信息
  ///
  static void cleanUser() {
    if (!SentryManager.isInit) {
      return;
    }
    Sentry.configureScope((scope) => scope.user = null);
  }

  /// 添加标签
  ///
  ///  标签是可搜索的
  ///
  /// [tagName] 标签名
  /// [value] 值
  static void addTag(String tagName, String value) {
    if (!SentryManager.isInit) {
      return;
    }
    if (tagName.isEmpty || value.isEmpty) {
      logger.e('#tagName: $tagName, #value: $value, 标签名称或值不能为空');
      return;
    }
    Sentry.configureScope((scope) => scope.setTag(tagName, value));
  }

  /// 添加面包屑
  ///
  /// [name] 名称
  static void addBreadcrumb(String name) {
    if (!SentryManager.isInit) {
      return;
    }
    if (name.isEmpty) {
      logger.e('面包屑名称不能为空!');
      return;
    }
    Sentry.addBreadcrumb(Breadcrumb(message: name));
  }

  /// 添加上下文
  ///
  /// 上下文是无法进行搜索的, 主要是提供更详细的debug信息
  /// 发送上下文时，请考虑有效负载大小限制。Sentry不建议在上下文中发送整个应用程序状态和大数据blob。
  /// 如果超过最大有效负载大小，Sentry将响应HTTP错误413 Payload Too Large并拒绝该事件。
  ///
  /// [name] 名称
  /// [data] 数据
  static void setContexts(String name, dynamic data) {
    if (!SentryManager.isInit) {
      return;
    }
    if (name.isEmpty) {
      logger.e('#name: $name, 名称或值不能为空');
      return;
    }
    Sentry.configureScope((scope) => scope.setContexts(name, data));
  }

  /// 捕获异常信息
  ///
  /// [exception] 描述
  /// [stackTrace] 堆栈信息
  static Future<void> exception(dynamic exception, {dynamic stackTrace}) async {
    if (!SentryManager.isInit) {
      return;
    }
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
    );
  }

  /// 捕获普通消息
  ///
  /// [message] 消息体
  static Future<void> message(String message, {SentryLevel? level, String? template, List<dynamic>? params}) async {
    if (!SentryManager.isInit) {
      return;
    }
    await Sentry.captureMessage(message, level: level, template: template, params: params);
  }
}
