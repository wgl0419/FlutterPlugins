library uni_websocket;

import 'package:web_socket_channel/web_socket_channel.dart';

import '_platform/_connect_api.dart'
    if (dart.library.html) '_platform/_connect_html.dart'
    if (dart.library.io) '_platform/_connect_io.dart' as platform;

typedef OpenCallback = void Function(UniWebSocket self);
typedef MessageCallback = void Function(UniWebSocket self, dynamic data);
typedef ErrorCallback = void Function(UniWebSocket self, dynamic error);
typedef CloseCallback = void Function(
    UniWebSocket self, int? code, String? reason);

class UniWebSocket {
  final String url;
  final Iterable<String>? protocols;
  final Map<String, dynamic>? headers;
  final Duration? pingInterval;

  /// 连接成功时回调
  OpenCallback? onOpen;

  /// 接收到消失时回调
  MessageCallback? onMessage;

  /// 发生异常时回调
  ErrorCallback? onError;

  /// 连接断开时回调
  CloseCallback? onClose;

  UniWebSocket(
    this.url, {
    this.protocols,
    this.headers,
    this.pingInterval,
    this.onOpen,
    this.onMessage,
    this.onError,
    this.onClose,
  });

  WebSocketChannel? _channelOrNull;
  int? _closeCodeOrNull;
  String? _closeReasonOrNull;

  /// 判断是否连接
  bool get isConnected => _channelOrNull != null;

  /// 连接
  ///
  /// [callOnError] 连接失败时是否回调 `onError`
  Future<void> connect({int connectFailureCode = -1, bool? callOnError}) async {
    try {
      await connectOrThrow();
    } catch (error) {
      if (callOnError == true) {
        onError?.call(this, error);
      }
      onClose?.call(this, connectFailureCode, error.toString());
    }
  }

  /// 连接
  ///
  /// 连接失败时抛出 `SocketException | IOException` 异常
  Future<void> connectOrThrow() async {
    final channel = await platform.connectOrThrow(
      url,
      protocols: protocols,
      headers: headers,
      pingInterval: pingInterval,
    );
    _channelOrNull = channel;
    _closeCodeOrNull = null;
    _closeReasonOrNull = null;
    onOpen?.call(this);
    channel.stream.listen(
      (data) => onMessage?.call(this, data),
      cancelOnError: false,
      onDone: () {
        onClose?.call(
          this,
          _closeCodeOrNull ?? channel.closeCode,
          _closeReasonOrNull ?? channel.closeReason,
        );
        _channelOrNull = null;
      },
      onError: (error) => onError?.call(this, error),
    );
  }

  /// 发送数据
  ///
  /// [data] 数据
  bool send(dynamic data) {
    if (_channelOrNull != null) {
      _channelOrNull!.sink.add(data);
      return true;
    }
    return false;
  }

  /// 关闭连接
  ///
  /// [closeCode]   关闭状态码
  /// [closeReason] 关闭原因
  Future<void> close([int? closeCode, String? closeReason]) async {
    if (_channelOrNull != null) {
      _closeCodeOrNull = closeCode;
      _closeReasonOrNull = closeReason;
      await _channelOrNull!.sink.close(closeCode, closeReason);
    }
    _channelOrNull = null;
  }
}
