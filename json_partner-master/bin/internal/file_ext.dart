import 'dart:io' as io;

import 'package:path/path.dart' as path;

import 'kt.dart';

extension FileExtensions on io.File {
  /// 获取文件名
  String get filename => path.basename(this.path);

  /// 获取没有后缀的文件名
  String get filenameWithoutSuffix =>
      filename.let((it) => it.substring(0, it.lastIndexOf('.')));
}
