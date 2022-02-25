import 'package:flutter/foundation.dart';
import 'package:flutter_base_kit/utils/encrypt_utils.dart';
import 'package:flutter_test/flutter_test.dart';

String publicKey = '''-----BEGIN PUBLIC KEY-----
MIGf
-----END PUBLIC KEY-----
''';

void main() {
  test('ase encode and decode', () {
    final data = EncryptUtils.aesEncrypt('hello', 'ASDFGHJKLASDFGHJ');
    final deData = EncryptUtils.aesDecrypt(data, 'ASDFGHJKLASDFGHJ');
    expect(deData, 'hello');
  });
  test('rsa encode and decode', () {
    final data = EncryptUtils.rsaEncrypt('123456789', publicKey: publicKey);
    debugPrint(data);
    final x = EncryptUtils.rsaDecrypt(data, publicKey: publicKey);
    debugPrint(x);
  });
}
