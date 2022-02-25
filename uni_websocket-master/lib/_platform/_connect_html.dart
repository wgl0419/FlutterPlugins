library uni_websocket;

import 'dart:html' as html;

import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<WebSocketChannel> connectOrThrow(
  String url, {
  Iterable<String>? protocols,
  Map<String, dynamic>? headers,
  Duration? pingInterval,
}) async {
  final ws = html.WebSocket(url);
  return HtmlWebSocketChannel(ws);
}
