import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:retry/retry.dart';

void main() {
  test('adds one to input values', () async {
    // int s = DateTime.now().millisecondsSinceEpoch;
    //
    // // await Future.delayed(Duration(seconds: 100));
    //  IOWebSocketChannel? channel;
    //  Stream? stream;

    try {
      var x = await retry(() async {
        print('connecting...');
        bool isConnected = await Future.delayed(const Duration(seconds: 3), () {
          return false;
        });
        if (!isConnected) {
          throw const WebSocketException('connecte error');
        }
        return isConnected;
      }, retryIf: (e) => e is WebSocketException);
      print(x);
    } catch (e) {
      print(e);
    }



    // try {
    //   WebSocket ws = await retry<WebSocket>(() async {
    //     String url = 'ws://baiduws.com';
    //     print('开始连接: $url');
    //     return await WebSocket.connect(url); // ws://achex.ca:4010
    //   }, retryIf: (e) => e is WebSocketException, maxAttempts: 3);
    //
    //   if (ws.readyState == 1) {
    //     print('连接成功!');
    //   } else {
    //     print('连接失败!');
    //   }
    // } catch (e) {
    //   print('连接失败!!!!!');
    // }
    // channel = IOWebSocketChannel(ws);
    // stream = channel.stream.asBroadcastStream();
    // await retry(
    //   () async {
    //     print('连接....');
    //     channel = IOWebSocketChannel.connect(Uri.parse('ws://achex.ca:4010'));
    //     stream = channel?.stream.asBroadcastStream();
    //     // await stream?.first;
    //     channel?.sink.add('ok');
    //   },
    //   retryIf: (e) {
    //     print(e);
    //     return true;
    //   },
    // );
    //
    // stream.listen((event) {
    //   print(channel?.innerWebSocket);
    //   print(event);
    // });
    // stream
    // //
    // // await Future.delayed(const Duration(seconds: 50));
    // channel.sink.add('ok');
    //
    // print('okokokokok');
  });
}
