import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

class HttpClientUtils {
  static Future<String> get(String url) async {
    final response = await http.get(Uri.parse(url));
    return response.body;
  }

  static Future<bool> download(String url, String path) async {
    Completer<bool> _completer = Completer();
    HttpClient client = HttpClient();
    client.getUrl(Uri.parse(url)).then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) async {
      await response.pipe(new File(path).openWrite());
      _completer.complete(true);
    }).catchError((e) {
      _completer.completeError(e);
    });
    return _completer.future;
  }
}
