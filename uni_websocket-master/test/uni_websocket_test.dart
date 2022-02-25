import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uni_websocket/uni_websocket.dart';

void main() {
  test('Test UniWebSocket', () async {
    final ws = UniWebSocket(
      "ws://127.0.0.1:8001",
      onOpen: (self) {
        print("onOpen:");
        self.send("Hello WebSocket!");
      },
      onMessage: (self, data) {
        print("onMessage: $data");
      },
      onError: (self, error) {
        print("onError: $error");
      },
      onClose: (self, code, reason) {
        print("onClose: $code, $reason");
        Future.delayed(const Duration(seconds: 1), () => exit(0));
      },
    );
    await ws.connect(callOnError: false);
    await Future.delayed(const Duration(days: 1));
  });
}
