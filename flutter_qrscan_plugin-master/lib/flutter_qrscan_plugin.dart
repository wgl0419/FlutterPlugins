library flutter_qrscan_plugin;

import 'dart:math';

import 'package:flutter/services.dart';

import 'src/barcode_format.dart';
import 'src/qr_scan_result.dart';

export 'src/barcode_format.dart';
export 'src/qr_scan_platform.dart';
export 'src/qr_scan_result.dart';
export 'src/qr_scan_view.dart';

class FlutterQrScanPlugin {
  static const _methodChannel =
      MethodChannel('dev.flutter.qrscan_plugin/FlutterQrScanPlugin');

  static Future<bool> setPossibleFormats(List<BarcodeFormat> formats) async {
    final result = await _methodChannel.invokeMethod(
        "setPossibleFormats", formats.map((it) => it.format).toList());
    return result;
  }

  static Future<QrScanResult?> analyzeImage(String path) async {
    final result = await _methodChannel.invokeMethod("analyzeImage", path);
    if (result == null) {
      return null;
    }
    final barcodeFormat = result['barcodeFormat'];
    final text = result['text'];
    final points = <Point<double>>[];
    result['points'].forEach((it) {
      points.add(Point<double>(it[0], it[1]));
    });
    return QrScanResult(
      barcodeFormat: barcodeFormat,
      text: text,
      points: points,
    );
  }

}
