import 'dart:async';

import 'package:flutter/services.dart';

import 'internal/libcipher.dart' as libcipher;

class FlutterCipherPlugin {
  static const MethodChannel _channel = const MethodChannel('flutter_cipher_plugin');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static String encrypt({required String plaintext, required String key}) =>
      libcipher.encrypt(key: key, plaintext: plaintext);

  static String decrypt({required String ciphertext, required String key}) =>
      libcipher.decrypt(key: key, ciphertext: ciphertext);
}
