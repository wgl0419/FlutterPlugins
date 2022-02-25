import 'dart:io';

import 'package:flutter_iconfont_builder/iconfont_utils.dart';
import 'package:yaml/yaml.dart';

final FontConfig fontConfig = FontConfig();

class FontConfig {
  late String _pubSpecString;
  String get pubSpecString => _pubSpecString;

  late YamlMap _pubSpec;
  YamlMap get pubSpec => _pubSpec;

  late YamlMap? _iconFontConfig;
  YamlMap? get iconFontConfig => _iconFontConfig;

  YamlList? get fonts => _iconFontConfig?['fonts'];

  void load() {
    _pubSpecString = File('pubspec.yaml').readAsStringSync();
    _pubSpec = (loadYaml(pubSpecString) as YamlMap);
    _iconFontConfig = _pubSpec['flutter_iconfont_builder'];
  }

  String get fontRelativeDir => _iconFontConfig?['ttf-file-path'] ?? 'assets/fonts';
  String get dartRelativeDir => _iconFontConfig?['dart-file-path'] ?? 'lib/generated';
  String get htmlRelativeDir => _iconFontConfig?['html-file-path'] ?? 'lib/generated';
  String? get mergeDartFile => _iconFontConfig?['merge-dart-file'];

  List? get flutterFont => _pubSpec['flutter']['fonts'];

  bool updatePubspec(String config) {
    if (IconFontUtils.writeToFile(config, 'pubspec.yaml')) {
      reload();
      return true;
    }
    return false;
  }

  void reload() {
    load();
  }
}
