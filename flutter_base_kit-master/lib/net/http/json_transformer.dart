part of http;

/// json 解析
///
/// 利用 isolate 解析大json字符串
class JsonTransformer {
  static Future<dynamic> decode(String data) async {
    final bool isCompute = data.length > 10 * 1024;
    final dynamic json =
        isCompute ? await compute(_decodeJson, data) : _decodeJson(data);
    return json;
  }
}

/// 解析数据
dynamic _decodeJson(String data) {
  return json.decode(data);
}
