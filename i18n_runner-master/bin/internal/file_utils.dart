import 'dart:io';

import 'package:crypto/crypto.dart';

class FileUtils {
  /// 判断是否为同一个文件
  static bool isSameFile(File f1, File f2) {
    if (f1.existsSync() && f2.existsSync()) {
      return f1.path == f2.path ||
          md5.convert(f1.readAsBytesSync()) ==
              md5.convert(f2.readAsBytesSync());
    }
    return false;
  }

  static void writeAsStringSync(File f, String contents) {
    if (!f.parent.existsSync()) {
      f.parent.createSync();
    }
    f.writeAsStringSync(contents);
  }

  static void watchModifyEvent(File f, void onModify(File)) {
    f.parent.watch().listen((event) {
      if (event is FileSystemModifyEvent && event.contentChanged) {
        if (isSameFile(f, File(event.path))) {
          onModify(f);
        }
      }
    });
  }
}
