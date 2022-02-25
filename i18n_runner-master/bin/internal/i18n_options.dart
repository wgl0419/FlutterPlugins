import 'dart:io' as io;

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

class I18nOptions {
  final String i18n_json;
  final String i18n_keys_dart;
  final String $translationsDir;
  final String benchmarkLocale;
  final YamlMap? $supportLocales;

  Map<String, String> get localeFieldMappings => $supportLocales != null
      ? Map.fromEntries($supportLocales!.entries
          .map((e) => MapEntry(e.key as String, e.value as String)))
      : {'zhCN': 'zh_CN', 'zhTW': 'zh_TW', 'en': 'en_US', 'ja': 'ja'};

  Map<String, io.File> get localeSourceMappings => Map.fromEntries(
        localeFieldMappings.entries.map(
          (e) => MapEntry(
            e.key,
            io.File(path.join($translationsDir, e.value + '.dart')),
          ),
        ),
      );

  I18nOptions({
    this.i18n_json = 'lib/i18n/i18n.json',
    this.i18n_keys_dart = 'lib/generated/i18n_keys.dart',
    this.$translationsDir = 'lib/i18n/translations/',
    this.benchmarkLocale = 'zhCN',
    this.$supportLocales,
  });

  Map<String, dynamic> toMap() {
    return {
      'i18n_json': this.i18n_json,
      'i18n_keys_dart': this.i18n_keys_dart,
      'localeFieldMappings': this.localeFieldMappings,
      'localeSourceMappings': this.localeSourceMappings,
    };
  }
}
