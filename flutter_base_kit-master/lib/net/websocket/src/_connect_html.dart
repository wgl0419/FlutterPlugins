import 'dart:html';

import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<WebSocketChannel> webSocketConnect(String url, {Duration? connectionTimeout, Object? protocols}) async {
  var websocket = WebSocket(url, protocols);
  Future onOpenEvent = websocket.onOpen.first;
  if (connectionTimeout != null) {
    onOpenEvent = onOpenEvent.timeout(connectionTimeout);
  }
  await onOpenEvent;
  return HtmlWebSocketChannel(websocket);
}
