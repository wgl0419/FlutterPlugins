library uni_websocket;

import 'package:web_socket_channel/web_socket_channel.dart';

Future<WebSocketChannel> connectOrThrow(
  String url, {
  Iterable<String>? protocols,
  Map<String, dynamic>? headers,
  Duration? pingInterval,
}) {
  throw UnsupportedError(
    'No implementation of the `connectOrThrow` api provided',
  );
}
