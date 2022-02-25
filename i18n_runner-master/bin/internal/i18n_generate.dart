import 'dart:convert' as convert;
import 'dart:io' as io;

const String WARN_HEADER = '''
// 警告: 这些代码 i18n_runner 自动生成的， 不要修改！不要修改！不要修改！
// WARN: DO NOT EDIT, THIS IS CODE GENERATED.

// ignore_for_file: prefer_single_quotes
// ignore: constant_identifier_names
''';

extension _CodeSafeExtensions on String {
  String get safeValueCode => this
      .replaceAll('\n', '\\n')
      .replaceAll('"', '\\"')
      .replaceAll('\$', '\\\$');

  String get safeComment => this.replaceAll('\n', '\\n');
}

String generateTranslationsCode(
  String fieldName,
  Map<String, String> dicts,
) {
  StringBuffer sb = StringBuffer();
  dicts.forEach((key, value) {
    sb.write('  "${key}": "${value.safeValueCode}",\n');
  });
  return '''
$WARN_HEADER
const Map<String, String> $fieldName = {
${sb.toString().trimRight()}
};
''';
}

String generateI18nKeysCode(
  String className,
  String rawClassName,
  Map<String, String> dicts,
) {
  final keys = dicts.entries.map((e) => '''
  /// ${e.value.safeComment}
  /// Use [$className.${e.key}].
  static String get ${e.key} => "${e.key}".tr;
''');
  final raw_keys = dicts.entries.map((e) => '''
  /// ${e.value.safeComment}
  /// Use [$rawClassName.${e.key}.tr] or [$rawClassName.${e.key}.trPlaceholder([...])].
  static String get ${e.key} => "${e.key}";
''');
  final code = '''
$WARN_HEADER
import 'package:get/get.dart';

abstract class $className {
${keys.join("\n").trimRight()}
}

abstract class $rawClassName {
${raw_keys.join("\n").trimRight()}
}

extension ${rawClassName}Extensions on String {
  /// 支持替换占位符
  String trPlaceholder([List<String> args = const []]) {
    var key = tr;
    if (args.isNotEmpty) {
      for (final arg in args) {
        key = key.replaceFirst(RegExp(r'{}'), arg.toString());
      }
    }
    return key;
  }
}
''';
  return code;
}

Map<String, Map<String, String>> collectSourceTranslations(
  Map<String, io.File> sources,
) {
  Map<String, Map<String, String>> translations = {};
  sources.forEach((locale, source) {
    if (!source.existsSync()) {
      return;
    }
    var lines = source.readAsLinesSync();
    StringBuffer sb = StringBuffer();
    lines.forEach((element) {
      if (element.trim() != "" &&
          !element.trim().startsWith("//") &&
          !element.trim().startsWith("import") &&
          !element.trim().startsWith("export") &&
          !element.trim().startsWith("part")) {
        sb.write(element);
      }
    });
    final regExp = RegExp(r"({.*,?})");
    final content = regExp
        .allMatches(sb
            .toString()
            .replaceAll("\n", "")
            .replaceAll(",}", "}")
            .replaceAll("\\\$", "\$"))
        .first
        .group(0)!;
    final Map<String, String> dicts = {};
    convert.jsonDecode(content).forEach((key, value) {
      dicts[key] = value;
    });
    translations[locale] = dicts;
  });
  return translations;
}

Map<String, Map<String, String>> collectJsonTranslations(
  io.File json,
) {
  Map<String, Map<String, String>> translations = {};
  if (!json.existsSync()) {
    return translations;
  }
  final excludeKeys = ["id", "key"];
  convert
      .jsonDecode(json.readAsStringSync())
      .forEach((e) => e.forEach((key, value) {
            if (!excludeKeys.contains(key)) {
              if (translations[key] == null) {
                translations[key] = {};
              }
              translations[key]![e["key"]] = value;
            }
          }));
  return translations;
}

Map<String, Map<String, String>> mergeTranslations(
  Map<String, Map<String, String>> master,
  Map<String, Map<String, String>> slave,
) {
  Map<String, Map<String, String>> translations = master;
  // 处理新增和更新的词条
  slave.forEach((locale, dicts) {
    dicts.forEach((key, value) {
      if (translations[locale] == null) {
        translations[locale] = {};
      }
      translations[locale]![key] = value;
    });
  });
  return translations;
}
