# UniWebSocket

Flutter WebSocket 连接



## 快速接入

在`pubspec.yaml`文件中添加一下依赖

```
dependencies:
  ...
  uni_websocket:
    git: git@gitlab.tqxd.com:flutter/plugins/uni_websocket.git
  ...
```

或者

```
dependencies:
  ...
  uni_websocket:
    version: <latest_version>
    hosted:
      name: uni_websocket
      url: https://pub.youzi.dev/api/

  ...
```



## 使用例程

```dart
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
    exit(0);
  },
);
try {
  await ws.connectOrThrow();
  await Future.delayed(const Duration(days: 1));
} catch (e) {
  print("Connect failure: $e");
}
```

