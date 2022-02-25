import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class EventUtils {
  /// md5
  static String encodeMd5(String data) {
    final content = Utf8Encoder().convert(data);
    final digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  /// 获取签名
  static String getSign(Map<String, dynamic> params, String appId, String appSecret, int timeStamp) {
    final keys = params.keys.toList();
    keys.sort((String a, String b) => a.compareTo(b));
    final paramsStr = keys.map((key) => '$key${params[key]}').toList().join('');
    String signStr = '$appId$paramsStr$appSecret$timeStamp';
    return EventUtils.encodeMd5(signStr);
  }

  /// 获取当前格式化的时间
  static String get currentDateTime {
    return DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  }
}
