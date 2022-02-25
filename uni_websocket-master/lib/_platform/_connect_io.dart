library uni_websocket;

import 'dart:io' as io;

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<WebSocketChannel> connectOrThrow(
  String url, {
  Iterable<String>? protocols,
  Map<String, dynamic>? headers,
  Duration? pingInterval,
}) async {
  final ws = await io.WebSocket.connect(
    url,
    protocols: protocols,
    headers: headers,
  );
  ws.pingInterval = pingInterval;
  return IOWebSocketChannel(ws);
}
