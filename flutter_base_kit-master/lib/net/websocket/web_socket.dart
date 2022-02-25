import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_base_kit/flutter_base_kit.dart';
import 'package:flutter_base_kit/pkg/logger/logger.dart';
import 'package:retry/retry.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'src/_connect_api.dart'
    if (dart.library.html) 'src/_connect_html.dart'
    if (dart.library.io) 'src/_connect_io.dart';

/// WebSocket状态
enum SocketStatus {
  /// 连接中
  connecting,

  /// 已连接
  connected,

  /// 失败
  failed,

  /// 连接关闭
  closed,
}

// typedef VoidCallback = dynamic Function();
class NeWebSocket {
  /// websocket服务器地址
  ///
  /// ex: ws://xxx, wss://xxx
  final String url;

  /// 是否打印日志
  final bool enableLog;

  /// webSocket 实例
  WebSocketChannel? _channel;

  WebSocketChannel? get channel => _channel;

  /// socket状态
  SocketStatus? _socketStatus;

  SocketStatus? get status => _socketStatus;

  /// 当连接打开
  VoidCallback onOpen;

  /// 接收到消息回调
  ValueChanged<dynamic> onMessage; // 接收消息回调

  /// 当连接关闭
  VoidCallback? onClose;

  /// 连接错误
  ValueChanged<WebSocketChannelException>? onError;

  /// 心跳定时器
  StreamSubscription<int>? _heartBeatSubscription;

  StreamSubscription<int>? get heartBeatSubscription => _heartBeatSubscription;

  /// 心跳间隔
  final Duration heartTimes;

  /// 心跳命令
  final AsyncValueGetter<dynamic>? heartMessage;

  /// 重连次数，默认10次
  final num reconnectCount;

  factory NeWebSocket(
    String url, {
    bool enableLog = false,
    required VoidCallback onOpen,
    required ValueChanged<dynamic> onMessage,
    required VoidCallback onClose,
    AsyncValueGetter<dynamic>? heartMessage,
    Duration heartTimes = const Duration(seconds: 3),
    ValueChanged<WebSocketChannelException>? onError,
    num reconnectCount = 8,
  }) =>
      NeWebSocket._(
        url,
        onOpen: onOpen,
        onMessage: onMessage,
        onClose: onClose,
        onError: onError,
        enableLog: enableLog,
        heartTimes: heartTimes,
        heartMessage: heartMessage,
        reconnectCount: reconnectCount,
      );

  NeWebSocket._(
    this.url, {
    required this.onOpen,
    required this.onMessage,
    this.onClose,
    this.onError,
    required this.enableLog,
    this.heartTimes = const Duration(seconds: 3),
    this.heartMessage,
    this.reconnectCount = 8,
  });

  /// 连接ws
  Future<bool> connect() async {
    _debugLog('准备连接: $url');
    _socketStatus = SocketStatus.connecting;
    close();
    try {
      _channel = await webSocketConnect(url);
      _socketStatus = SocketStatus.connected;
      onOpen();
      // 注册监听器
      _channel?.stream.listen((dynamic data) => _onMessage(data), onError: _onError, onDone: _onClose);
    } on WebSocketException catch (e) {
      _onError(WebSocketChannelException(e.message));
      return false;
    } catch (e) {
      _onError(WebSocketChannelException.from(e));
      return false;
    }
    return true;
  }

  /// 发送WebSocket消息
  ///
  /// [message] 消息内容
  void send(dynamic message) {
    if (_channel != null) {
      switch (_socketStatus) {
        case SocketStatus.connected:
          _debugLog('发送消息：$message');
          _channel?.sink.add(message);
          break;
        case SocketStatus.closed:
          _debugLog('连接已关闭');
          break;
        case SocketStatus.failed:
          _debugLog('发送失败');
          break;
        default:
          break;
      }
    }
  }

  /// 重连机制
  Future<void> reconnect() async {
    await retry<bool>(() async {
      final isConnected = await connect();
      if (!isConnected) throw const WebSocketException('connected error');
      return isConnected;
    }, retryIf: (e) => e is WebSocketException);
  }

  /// 初始化心跳
  void initHeartBeat() {
    destroyHeartBeat();
    _heartBeatSubscription = Stream.periodic(heartTimes, (int i) {
      return i;
    }).listen((_) async {
      /// 发送心跳
      await sentHeart();
    });
  }

  /// 发送心跳
  Future<void> sentHeart() async {
    if (heartMessage != null && status == SocketStatus.connected) {
      send(await heartMessage!());
    }
  }

  /// 销毁心跳
  void destroyHeartBeat() {
    _heartBeatSubscription?.cancel();
  }

  /// 关闭socket连接
  void close() {
    if (_channel != null) {
      _debugLog('连接关闭');
      _socketStatus = SocketStatus.closed;
      destroyHeartBeat();
      _channel?.sink.close();
    }
  }

  void _onMessage(dynamic data) {
    _debugLog('接收到消息');
    _debugLog(data.toString());
    onMessage(data);
  }

  void _onError(dynamic e) {
    _socketStatus = SocketStatus.failed;
    final WebSocketChannelException error = e as WebSocketChannelException;
    _errorLog('连接出错! - (${error.message})');
    if (onError != null) {
      onError!(error);
    }
    close();
  }

  void _onClose() {
    _debugLog('连接关闭!');
    _socketStatus = SocketStatus.closed;
    if (onClose != null) {
      onClose!();
    }
  }

  /// 打印日志
  void _debugLog(String msg) {
    if (enableLog) {
      logger.d('【WebSocket】$msg');
    }
  }

  void _errorLog(String msg) {
    if (enableLog) {
      logger.e('【WebSocket】$msg');
    }
  }
}

class WebSocketException implements Exception {
  final String message;

  const WebSocketException([this.message = ""]);

  String toString() => "WebSocketException: $message";
}
