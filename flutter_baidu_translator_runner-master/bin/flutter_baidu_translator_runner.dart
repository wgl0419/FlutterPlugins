import 'dart:convert';
import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:flutter_baidu_translator_runner/translator_utils.dart';
import 'package:recase/recase.dart';
import 'package:retry/retry.dart';
import 'package:yaml/yaml.dart';

import 'package:dartx/dartx.dart';

List<String> supportLangs = [
  'zh',
  'en',
  'jp',
  'kor',
  'yue',
  'cht',
  'wyw',
  'fra',
  'spa',
  'th',
  'ru',
  'it',
  'de',
  'pt',
  'vie'
];

typedef Future<T> AsyncFuntion<T>();

Future<T> runTask<T>(String msg, AsyncFuntion asyncFuntion) async {
  Progress progress = logger.progress(msg);
  final result = await asyncFuntion.call();
  progress.finish(showTiming: true);
  return result as T;
}

late Logger logger;
late String yamlString;
late YamlMap config;
late YamlMap? translatorConfig;
void main(List<String> args) async {
  bool verbose = args.contains('-v');
  logger = verbose ? Logger.verbose(ansi: Ansi(true)) : Logger.standard(ansi: Ansi(true));
  yamlString = File('pubspec.yaml').readAsStringSync();
  config = (loadYaml(yamlString) as YamlMap);

  translatorConfig = config['flutter_baidu_translator_runner'];
  if (translatorConfig == null) {
    logger.stderr('${logger.ansi.yellow}warring: Translator configuration item not found${logger.ansi.none}');
    exit(-1);
  }

  final String? primaryKey = translatorConfig?['config']['primary-key'];
  final int? autoPrimaryKey = translatorConfig?['config']['auto-primary-key'];

  final String? fromPath = translatorConfig?['from_path'];
  if (fromPath.isNullOrEmpty || File(fromPath!).existsSync() == false) {
    logger.stderr('${logger.ansi.yellow}warring: from_path is invalid${logger.ansi.none}');
    exit(-1);
  }

  final String? baseKey = translatorConfig?['config']['base-key'];
  if (baseKey.isNullOrEmpty) {
    logger.stderr('${logger.ansi.yellow}warring: config:baseKey is invalid${logger.ansi.none}');
    exit(-1);
  }

  final YamlMap? langs = translatorConfig?['config']['langs'];
  if (langs == null || langs.isEmpty || langs.keys.isEmpty) {
    logger.stderr('${logger.ansi.red}warring: config:langs is not set!${logger.ansi.red}');
    exit(-1);
  }
  final availableLangs =
      langs.keys.filter((key) => supportLangs.contains(key)).toSet().map((key) => {key: langs[key]}).toList();
  if (availableLangs.isEmpty) {
    logger.stderr('${logger.ansi.red}warring: No language available!${logger.ansi.red}');
    exit(-1);
  }

  var text = File(fromPath).readAsStringSync();
  var fromJson = json.decode(text);

  if (fromJson.runtimeType.toString().contains('List<')) {
    final bool supportEng = langs.keys.contains('en');
    final String? engAliasKey = langs['en'];
    final bool? regen = translatorConfig?['config']['regen'];
    final int? caseType = translatorConfig?['config']['case-type'];
    final String? destPath = translatorConfig?['dest_path'];
    if (destPath.isNotNullOrEmpty) {
      File destFile = File(destPath!);
      if (!destFile.existsSync()) {
        destFile.createSync(recursive: true);
      }
    }
    for (var i in fromJson) {
      int index = fromJson.indexOf(i);
      String ph = '@@';
      String? str = i[baseKey];
      if (str.isNullOrEmpty) {
        logger.stdout(
            '${logger.ansi.yellow}warring: this dict [${baseKey}] value is null or empty, Skiped!${logger.ansi.none}');
        continue;
      } else {
        str = str?.replaceAll('\n', ph);
      }
      await runTask('[${index + 1}/${fromJson.length}]start trans: $str', () async {
        for (final langMap in availableLangs) {
          final langKey = langMap.keys.first;
          final aliasKey = langMap.values.first;
          final String? s = fromJson[index][aliasKey ?? langKey];
          if (s.isNotNullOrEmpty && regen == false) {
            continue;
          }

          await retry<void>(() async {
            final result = await TranslatorUtils.trans(str!, langKey!);
            fromJson[index][aliasKey ?? langKey] = result.toString().replaceAll(ph, '\n');
          }, retryIf: (e) => e is TranslatorException, maxAttempts: 3);
        }

        if (primaryKey.isNotNullOrEmpty && supportEng) {
          // 判断key是否有值
          final String? keyValue = fromJson[index][primaryKey];
          if (!(autoPrimaryKey == -1 || (keyValue.isNotNullOrEmpty && autoPrimaryKey == 0))) {
            var val = fromJson[index][engAliasKey ?? 'en']
                .toString()
                .replaceAll('null', '')
                .replaceAll(RegExp(r"[^\w\ ]"), '');
            if (!val.startsWith(RegExp(r'^[a-zA-Z]'))) {
              val = 't$val';
            }
            if (val.length == 1) {
              val = '$val${DateTime.now().microsecond}';
            }
            fromJson[index][primaryKey] = caseType == 2 ? val.snakeCase : val.camelCase;
          }
        }
        if (destPath != null && destPath.toString().isNotEmpty) {
          File(destPath).writeAsStringSync(json.encode(fromJson));
        }
      });
    }
  } else {
    logger.stderr('${logger.ansi.red}warring: not support ${fromJson.runtimeType}${logger.ansi.none}');
    exit(-1);
  }
  exit(0);
}
