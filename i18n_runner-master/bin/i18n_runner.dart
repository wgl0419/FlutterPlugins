import 'dart:convert';
import 'dart:io' as io;

import 'package:cli_util/cli_logging.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'internal/debug.dart';
import 'internal/file_utils.dart';
import 'internal/i18n_generate.dart';
import 'internal/i18n_options.dart';

void main(List<String> args) async {
  final taskChain = _TaskChain(args);

  late final I18nOptions options;
  taskChain.addTask("获取配置信息", () {
    options = getI18nOptions();
    debugPrint(options.toMap());
  });

  late final Map<String, Map<String, String>> translations_source;
  taskChain.addTask("收集源代码翻译词条", () {
    translations_source =
        collectSourceTranslations(options.localeSourceMappings);
    debugPrint("=================== translations_source ===============");
    debugPrint(translations_source);
  });

  late final Map<String, Map<String, String>> translations_json;
  taskChain.addTask("收集JSON文件翻译词条", () {
    translations_json = collectJsonTranslations(io.File(options.i18n_json));
    debugPrint("=================== translations_json ===============");
    debugPrint(translations_json);
  });

  late final Map<String, Map<String, String>> translations;
  taskChain.addTask("合并翻译词条", () {
    translations = mergeTranslations(translations_source, translations_json);
    debugPrint("=================== translations ===============");
    debugPrint(translations);
  });

  taskChain.addTask("生成dart代码并写入到代码文件", () {
    translations.forEach((locale, dicts) {
      if (options.localeFieldMappings[locale] == null) {
        return;
      }
      debugPrint("=================== $locale ===============");
      final dicts_code =
          generateTranslationsCode(options.localeFieldMappings[locale]!, dicts);
      // 将代码写入文件
      FileUtils.writeAsStringSync(
        options.localeSourceMappings[locale]!,
        dicts_code,
      );
    });
  });

  taskChain.addTask("生成i18n keys代码并写入到代码文件", () {
    final i18n_keys_code = generateI18nKeysCode(
      "I18nKeys",
      "I18nRawKeys",
      translations[options.benchmarkLocale] ?? {},
    );
    debugPrint("=================== i18n_keys_code ===============");
    debugPrint(i18n_keys_code);

    // 将代码写入文件
    FileUtils.writeAsStringSync(
      io.File(options.i18n_keys_dart),
      i18n_keys_code,
    );
  });

  taskChain.addTask("生成`i18n.g.csv`翻译词条文件", () {
    final i18n_list =
        jsonDecode(new io.File(options.i18n_json).readAsStringSync());
    final languages = options.localeFieldMappings.keys;
    StringBuffer sb = new StringBuffer();
    sb.write('"' + [...languages, 'Key'].join('","') + '"\n');
    for (var it in i18n_list) {
      final row = [
        ...languages.map((e) => it[e].replaceAll('"', '""')),
        it['key']
      ];
      sb.write('"' + row.join('","') + '"\n');
    }
    FileUtils.writeAsStringSync(
      io.File(path.join(io.File(options.i18n_json).parent.path, 'i18n.g.csv')),
      sb.toString(),
    );
  });

  taskChain.runTasks();
}

I18nOptions getI18nOptions() {
  final i18nspec = (loadYaml(
    io.File('pubspec.yaml').readAsStringSync(),
  ) as YamlMap)['i18n_runner'];
  final options = I18nOptions(
    i18n_json: i18nspec?['files']?['json'] ?? 'lib/i18n/i18n.json',
    i18n_keys_dart:
        i18nspec?['files']?['i18n_keys'] ?? 'lib/generated/i18n_keys.dart',
    $translationsDir:
        i18nspec?['files']?['translations'] ?? 'lib/i18n/translations/',
    benchmarkLocale: i18nspec?['locale']?['benchmark'] ?? 'zhCN',
    $supportLocales: i18nspec?['locale']?['supports'],
  );
  return options;
}

class _TaskChain {
  final List<String> commandArgs;
  final names = <String>[];
  final tasks = <Function>[];
  late final Logger logger;

  _TaskChain(this.commandArgs) {
    final bool verbose = commandArgs.contains('-v');
    logger = verbose
        ? Logger.verbose(ansi: Ansi(true))
        : Logger.standard(ansi: Ansi(true));
  }

  void addTask(String name, Function task) {
    names.add(name);
    tasks.add(task);
  }

  void runTasks() async {
    for (var i = 0; i < tasks.length; i++) {
      final progress = logger.progress(
        '[${i + 1}/${tasks.length}] ${names[i]}',
      );
      await tasks[i]();
      progress.finish(showTiming: true);
    }
    logger.stdout('All ${logger.ansi.emphasized('done')}.');
  }
}
