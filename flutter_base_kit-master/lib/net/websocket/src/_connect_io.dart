import 'dart:io';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<WebSocketChannel> webSocketConnect(String url, {Duration? connectionTimeout, Object? protocols}) async {
  var websocket = WebSocket.connect(url);
  if (connectionTimeout != null) {
    websocket = websocket.timeout(connectionTimeout);
  }
  final webSocket = await websocket;
  return IOWebSocketChannel(webSocket);
}
