import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FlutterAimallFaceRecognition {
  static const MethodChannel _channel = const MethodChannel('flutter_aimall_face_recognition');

  static String? imoKey;

  /// 初始化爱莫sdk
  ///
  /// [key] 爱莫提供的key
  static Future<bool> initImoSDK(String? key, String? languageType) async {
    imoKey = key ?? '';
    final result = await _channel.invokeMethod('initImoSDK', {"imoKey": imoKey, "languageType": languageType ?? ''});
    return result['code'] == 200;
  }

  /// 动作活体检测
  ///
  static Future<File> actionLiving() async {
    assert(imoKey != null, '请先调用 initImoSDK 初始化!');
    final result = await _channel.invokeMethod('actionLiving');
    if (result['code'] == 200) {
      return File(result['image']);
    } else if (result['code'] == -1) {
      throw FaceException(-1, '用户主动取消');
    } else {
      throw Exception('人脸识别失败!');
    }
  }

  /// 静默活体检测
  ///
  static Future<SilentLivingResponse> silentLiving({String? userName}) async {
    assert(imoKey != null, '请先调用 initImoSDK 初始化!');
    final result = await _channel.invokeMethod('silentLiving', {"userName": userName ?? ''});
    if (result['code'] == 200) {
      return SilentLivingResponse(File(result['image']), result['faceToken']);
    } else if (result['code'] == -1) {
      throw FaceException(-1, '用户主动取消');
    } else {
      throw Exception('人脸识别失败!');
    }
  }

  /// 实名认证活体采集
  ///
  static Future<LivingSamplingResponse> livingSampling() async {
    assert(imoKey != null, '请先调用 initImoSDK 初始化!');
    final result = await _channel.invokeMethod('livingSampling');
    if (result['code'] == 200) {
      return LivingSamplingResponse(
          image1: File(result['image1']),
          image2: File(result['image2']),
          image3: File(result['image3']),
          video: File(result['video']));
    } else if (result['code'] == -1) {
      throw FaceException(-1, '用户主动取消');
    } else {
      throw Exception('人脸识别失败!');
    }
  }

  /// 图片对比
  ///
  /// [originImage] 原图
  /// [targetImages] 对比图
  ///
  static Future<double> faceSimilarityComparison(String? originImage, List<String>? targetImages) async {
    assert(imoKey != null, '请先调用 initImoSDK 初始化!');
    final result = await _channel.invokeMethod("faceSimilarityComparison", {
      "originImage": originImage ?? '',
      "targetImages": targetImages ?? ['']
    });
    if (result['code'] == 200) {
      return result["score"];
    } else if (result['code'] == -1) {
      throw FaceException(-1, '初始化失败');
    } else {
      throw Exception('是被失败!');
    }
  }

  /// 保存人脸信息到本地
  ///
  /// [userId] 用户ID
  /// [email] 用户邮箱
  /// [mobile] 手机号
  /// [faceToken] 服务端返回的人脸唯一标识
  /// [faceImage] 人脸图片信息
  static Future<bool> saveFaceToLocal(
      String? userId, String? email, String? mobile, String? faceToken, String? faceImage) async {
    assert(imoKey != null, '请先调用 initImoSDK 初始化!');
    final result = await _channel.invokeMethod("saveFaceToLocal", {
      "userId": userId ?? '',
      "email": email ?? '',
      "mobile": mobile ?? '',
      "faceToken": faceToken ?? '',
      "faceImage": faceImage ?? ''
    });
    return result['code'] == 200;
  }

  /// 更新人脸token
  ///
  /// [userId] 用户ID
  /// [faceToken] 服务端返回的人脸唯一标识
  static Future<bool> updateFaceToken(String? userId, String? faceToken) async {
    assert(imoKey != null, '请先调用 initImoSDK 初始化!');
    final result = await _channel.invokeMethod("updateFaceToken", {
      "userId": userId ?? '',
      "faceToken": faceToken ?? '',
    });
    return result['code'] == 200;
  }

  /// 删除人脸信息
  ///
  /// [faceToken] 人脸信息
  static Future<bool> deleteFaceToken(String? faceToken) async {
    final result = await _channel.invokeMethod("deleteFaceToken", {"faceToken": faceToken ?? ''});
    return result['code'] == 200;
  }

  /// 删除所有人脸信息
  static Future<bool> deleteAllUserFace(String faceToken) async {
    final result = await _channel.invokeMethod("deleteAllUserFace");
    return result['code'] == 200;
  }

  /// 清空临时缓存目录
  static Future<void> cleanCache() async {
    await _channel.invokeMethod("cleanCache");
  }

  /// 卡片拍照
  ///
  /// [isFront] 是否为头像面, 是的话会调用人脸识别取出人脸
  static Future<CardResponse> takeCardImage({bool isFront = false}) async {
    final result = await _channel.invokeMethod("takeCardImage", {"isFront": isFront});
    if (result['code'] == 200) {
      return CardResponse(
          isFront: isFront,
          image: File(result['image']),
          headImage: result['headImage'] != null ? File(result['headImage']) : null);
    } else if (result['code'] == -1) {
      throw FaceException(-1, '用户主动取消');
    } else {
      throw Exception('拍照失败!');
    }
  }
}

@immutable
class LivingSamplingResponse {
  final File? image1;
  final File? image2;
  final File? image3;
  final File? video;

  const LivingSamplingResponse({this.image1, this.image2, this.image3, this.video});

  @override
  String toString() {
    return 'LivingSamplingResponse{image1: ${image1?.path}, image2: ${image2?.path}, image3: ${image3?.path}, video: ${video?.path}}';
  }
}

@immutable
class SilentLivingResponse {
  final File? image;
  final String? faceToken;

  const SilentLivingResponse(this.image, this.faceToken);

  @override
  String toString() {
    return 'SilentLivingResponse{image: ${image?.path}, faceToken: $faceToken}';
  }
}

class FaceException implements Exception {
  int? code;
  String? cause;

  FaceException(this.code, this.cause);
}

@immutable
class CardResponse {
  final bool? isFront;
  final File? image;
  final File? headImage;

  const CardResponse({this.isFront, this.image, this.headImage});

  @override
  String toString() {
    return 'CardResponse{isFront: $isFront, image: ${image?.path}, headImage: ${headImage?.path}}';
  }
}
