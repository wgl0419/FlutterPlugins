import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_turui_ocr/model.dart';

class FlutterTuruiOcr {
  static const MethodChannel _channel =
      const MethodChannel('exchange.sgp.flutter/flutter_turui_ocr');

  /// 初始化sdk
  static Future<bool> initSdk() async {
    return await _channel.invokeMethod('initSdk');
  }

  /// 进行OCR识别
  static Future<OCRResultInfo> identify() async {
    final result = await _channel.invokeMethod('identify');
    if (result is Map) {
      return OCRResultInfo.fromJson(result);
    }
    throw Exception('OCR识别错误!');
  }

  /// 反初始化sdk
  static Future<void> deInitSdk() async {
    await _channel.invokeMethod('deInitSdk');
  }
}
