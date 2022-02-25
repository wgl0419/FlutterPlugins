# flutter_turui_ocr

厦门图睿OCR证件识别，Flutter 插件！

官方文档: [点击打开](http://showdoc.xmheshu.com/web/#/83?page_id=1673)

## 开始使用

### 安装

```yaml
flutter_turui_ocr:
    hosted:
      name: flutter_turui_ocr
      url: https://pub.youzi.dev/api/
    version: <last_version>
```

### 配置iOS

无需配置

### 配置 Android

需要在 `android/build.gradle` 加入

```
allprojects {
    repositories {
        // 加入👇这行
        maven {
            url 'http://nexus.tqxd.com/repository/maven-releases/'
        }
        google()
        jcenter()
    }
}
```

### dart

```dart
import 'package:flutter_turui_ocr/flutter_turui_ocr.dart';
```

#### 1. 初始化OCR引擎 **必须**

```dart
await FlutterTuruiOcr.initSdk();
```

#### 2. 识别证件

```dart
OCRResultInfo resultInfo = await FlutterTuruiOcr.identify();
```

OCRResultInfo

| 参数     | 描述              | 类型  | 默认值 |
| -------- | ----------------- | ----- | ------ |
| isFront | 是否为正面 | bool | false | 
| frontCardInfo | 证件正面信息 | FrontCardInfo | Null | 
| backCardInfo | 证件背面信息 | BackCardInfo | Null | 

FrontCardInfo

| 参数     | 描述              | 类型  | 默认值 |
| -------- | ----------------- | ----- | ------ |
| realName | 真实姓名 | String | Null | 
| idCardNum | 身份证号 | String | Null | 
| image | 身份证图片 | File | Null | 
| headImage | 身份证头像 | File | Null | 

#### 3. 释放OCR引擎

```dart
FlutterTuruiOcr.deInitSdk();
```

## Changelog

Refer to the [Changelog](CHANGELOG.md) to get all release notes.

