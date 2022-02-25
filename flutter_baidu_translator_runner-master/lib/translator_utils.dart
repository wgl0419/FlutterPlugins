import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';

class TranslatorUtils {
  static Future<String> trans(String str, String to) async {
    String apiHost = 'http://api.fanyi.baidu.com/api/trans/vip/translate';
    const appid = '20200930000577136';
    const key = 'KotqXzGTS3PXBx1NNBvm';
    var salt = (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();
    const from = 'zh';
    var str1 = '$appid$str$salt$key';
    var sign = encryptMD5(str1);
    var data = {'q': str, 'appid': appid, 'salt': salt, 'from': from, 'to': to, 'sign': sign};
    final res = await http.post(Uri.parse(apiHost), body: data);
    if (res.statusCode == 200) {
      final body = json.decode(res.body);
      if (body['trans_result'] != null) {
        return body['trans_result'][0]['dst'];
      }
      throw TranslatorException('trans_result is null');
    }
    print('error... [$str]');
    throw TranslatorException('error... [$str]');
  }

  static String encryptMD5(String data, [String? salt]) {
    var content = const Utf8Encoder().convert(salt == null ? data : '$data$salt');
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  static Directory createDirIsNotExists(String dir) {
    final _path = Directory(dir);
    if (!_path.existsSync()) {
      _path.createSync(recursive: true);
    }
    return _path;
  }
}

class TranslatorException implements Exception {
  final dynamic message;

  TranslatorException([this.message]);

  String toString() {
    Object? message = this.message;
    if (message == null) return "Exception";
    return "Exception: $message";
  }
}
