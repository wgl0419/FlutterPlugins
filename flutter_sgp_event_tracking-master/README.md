# flutter_sgp_event_tracking

交易所埋点Flutter插件

## 安装

```yaml
flutter_sgp_event_tracking:
    hosted:
      name: flutter_sgp_event_tracking
      url: https://pub.youzi.dev/api/
    version: <last_version>
```

## 使用

### 1. 初始化

引入插件

```dart
import 'package:flutter_sgp_event_tracking/flutter_sgp_event_tracking.dart';
```

```dart
FlutterSgpEventTracking
    .init(appId: appId, appSecret: appSecret, apiHost: apiHost);
```

以下参数由中台提供

- appId: 应用ID
- appSecret: 应用安全码
- apiHost: api地址

### 2. 埋点

中台默认提供了6种埋点类型，sdk实现了其中4种.

#### 1. 启动日志上报（热启动/冷启动）

> 所需参数已经由sdk内部进行设置

```dart
/// 热启动
FlutterSgpEventTracking.hotBotEvent();

/// 冷启动
FlutterSgpEventTracking.coldBotEvent();

/// 装机事件
FlutterSgpEventTracking.installEvent();
```

#### 2. 页面加载事件

```dart
FlutterSgpEventTracking
    .pageEvent(
                pageCode: '',                
                eventCode: '',
                loadType: '',
                operatingItems: '',
                eventDescription: '');
```

参数:
- pageCode: 页面编码
- eventCode: 事件编码
- loadType: 调用方式
- operatingItems: 操作事项
- eventDescription: 事件描述

#### 3. 操作事件

```dart
FlutterSgpEventTracking
    .operateEvent(
                pageCode: '',                
                eventCode: '',
                loadType: '',
                operatingItems: '',
                eventDescription: '');
```

参数:
- pageCode: 页面编码
- eventCode: 事件编码
- loadType: 调用方式
- operatingItems: 操作事项
- eventDescription: 事件描述

#### 4. 自定义事件

```dart
FlutterSgpEventTracking
    .event(EventTracking);
```

自定义事件class, 并继承 `EventTracking`, 重写对应的方法与属性. 可参考 `PageEvent`。