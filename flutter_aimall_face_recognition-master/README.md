# flutter_aimall_face_recognition

爱莫科技人脸识别, Flutter Package!

官方文档: [点击打开](https://console.aimall-tech.com/doc/api/15)

## 开始使用

### 安装

```yaml
flutter_aimall_face_recognition:
    hosted:
      name: flutter_aimall_face_recognition
      url: https://pub.youzi.dev/api/
    version: <last_version>
```

### 配置iOS

插件引用了 `cocopods` 私有库, 所以需要在 **Podfile** 增加如下配置：

```ruby
source 'git@gitlab.tqxd.com:aitd_exchange/aitd_exchange_mobile/native/podspec.git'
source 'https://github.com/CocoaPods/Specs.git'
```

### 配置 Android

无需配置

### dart

```dart
import 'package:flutter_aimall_face_recognition/flutter_aimall_face_recognition.dart';
```

#### 1. 初始化引擎 **必须**

```dart
FlutterAimallFaceRecognition.initImoSDK("imoKey","languageType");
```

#### 2. 动作活体检测

```dart
File image = await FlutterAimallFaceRecognition.actionLiving();
```

#### 3. 静默活体检测

```dart
SilentLivingResponse response = await FlutterAimallFaceRecognition.silentLiving({userName: ''});
```

SilentLivingResponse

| 参数     | 描述              | 类型  | 默认值 |
| -------- | ----------------- | ----- | ------ |
| image | 图片 | File | Null | 
| faceToken | faceToken | String | Null |

> 当faceToken不为空时, 则表示有匹配到本地的人脸信息
 
#### 4. 实名认证活体采集

```dart
LivingSamplingResponse res =
                      await FlutterAimallFaceRecognition.livingSampling();
```

LivingSamplingResponse

| 参数     | 描述              | 类型  | 默认值 |
| -------- | ----------------- | ----- | ------ |
| image1 | 活体1 | File | Null | 
| image2 | 活体2 | File | Null | 
| image3 | 活体3 | File | Null | 
| video | 活体视频 | File | Null | 

#### 5. 活体比对

```dart
double score = await FlutterAimallFaceRecognition
                      .faceSimilarityComparison("", [""]);
```

#### 6. 保存人脸信息到本地

```dart
bool success = await FlutterAimallFaceRecognition.saveFaceToLocal(
                                     "userId",
                                     "userEmail",
                                     "userMobile",
                                     "factToken",
                                     imagePath);
```

#### 7. 更新本地人脸信息

```dart
bool success = await FlutterAimallFaceRecognition.updateFaceToken(userId, faceToken);
```

#### 8. 删除人脸信息

删除指定人脸信息

```dart
bool success = await FlutterAimallFaceRecognition.deleteFaceToken(faceToken);
```

清空所有本地人脸信息

```dart
bool success = await FlutterAimallFaceRecognition.deleteAllUserFace();
```

#### 9. 删除本地临时图片缓存

```dart
await FlutterAimallFaceRecognition.cleanCache();
```

#### 10. 卡片拍照识别

```dart
CardResponse response =
                      await FlutterAimallFaceRecognition.takeCardImage(
                          isFront: true);
```

CardResponse

| 参数     | 描述              | 类型  | 默认值 |
| -------- | ----------------- | ----- | ------ |
| isFront | 是否是正面 | bool | Null | 
| image | 卡片图片 | File | Null | 
| headImage | 头像图片 | File | Null | 

> 当 isFront 为 true 时, 拍照完成后开启爱莫人脸识别, 取出头像图片

## Changelog

Refer to the [Changelog](CHANGELOG.md) to get all release notes.

## 感谢

Android: Fork [LibFace](https://github.com/Seasonallan/LibFace)
