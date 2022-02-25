import 'dart:io' as io;

import 'package:cli_util/cli_logging.dart';
import 'package:path/path.dart' as path;
import 'package:process_run/process_run.dart';
import 'package:yaml/yaml.dart';

import 'internal/consts.dart';
import 'internal/debug.dart';
import 'internal/file_ext.dart';
import 'internal/kt.dart';

void main(List<String> args) async {
  final taskChain = _TaskChain(args);

  // 模块名
  late final String moduleName;
  // 源码目录
  final libDir = io.Directory('lib');
  // 生成的 json partner 代码目录
  final generatedDir = io.Directory(
    path.join('lib', 'generated', 'json_partner'),
  ).also((it) {
    if (it.existsSync()) {
      it.deleteSync(recursive: true);
    }
    it.createSync(recursive: true);
  });
  // 待处理的JSON模型类列表
  final pendingJsonDartModelList = <_JsonDartModel>[];

  //region 1# 提取模块名称
  taskChain.addTask('提取模块名称', () {
    moduleName = (loadYaml(
      io.File('pubspec.yaml').readAsStringSync(),
    ) as YamlMap)['name'];
  });
  //endregion

  //region 2# 收集要处理的JSON模型类
  taskChain.addTask('收集要处理的JSON模型类', () {
    void collect(io.FileSystemEntity root, List<_JsonDartModel> models) {
      if (root is io.File) {
        final model = _JsonDartModel.tryCreate(root);
        if (model != null) {
          models.add(model);
        }
      } else if (root is io.Directory) {
        root.listSync().forEach((it) => collect(it, models));
      }
    }

    collect(libDir, pendingJsonDartModelList);
  });
  //endregion

  //region 3# 预处理JSON模型类
  taskChain.addTask('预处理JSON模型类', () {
    for (var model in pendingJsonDartModelList) {
      final lines = model.dartFile.readAsLinesSync();
      int lastImportStatementNumber = 0;
      int partDartGFileNumber = -1;
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.startsWith('import')) {
          lastImportStatementNumber = i;
        } else if (line.startsWith('part') &&
            (line.contains("part '${model.dartGFile.filename}';") ||
                line.contains('part "${model.dartGFile.filename}";'))) {
          partDartGFileNumber = i;
        }
      }
      if (partDartGFileNumber == -1) {
        lines.insert(lastImportStatementNumber + 1,
            "part '${model.dartGFile.filename}';");
      }
      model.dartFile.writeAsStringSync(lines.join('\r\n'));
    }
  });
  //endregion

  //region 4# 执行 `flutter pub run build_runner clean` 命令
  taskChain.addTask(
    "执行 ${taskChain.logger.ansi.subtle('`flutter pub run build_runner clean`')} 命令",
    () async {
      final result = await runExecutableArguments(
          'flutter', ['pub', 'run', 'build_runner', 'clean']);
      if (result.exitCode != 0) {
        taskChain.logger.stdout(
            '${taskChain.logger.ansi.emphasized('failed')}, code: ${result.exitCode}, ${result.stderr}, ${result.stdout}');
        io.exit(result.exitCode);
      }
    },
  );
  //endregion

  //region 5# 执行 `flutter pub run build_runner build --delete-conflicting-outputs` 命令
  taskChain.addTask(
    "执行 ${taskChain.logger.ansi.subtle('`flutter pub run build_runner build --delete-conflicting-outputs`')} 命令",
    () async {
      final result = await runExecutableArguments('flutter', [
        'pub',
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs'
      ]);
      if (result.exitCode != 0) {
        taskChain.logger.stdout(
            '${taskChain.logger.ansi.emphasized('failed')}, code: ${result.exitCode}, ${result.stderr}, ${result.stdout}');
        io.exit(result.exitCode);
      }
    },
  );
  //endregion

  //region 6# 生成 json_partner 代码
  taskChain.addTask('生成 json_partner 代码', () {
    final dartFiles = <io.File>[];
    final dartGFiles = <io.File>[];
    final classNames = <String>[];

    // 处理xxx.g.dart
    void handleDartGFile() {
      for (var model in pendingJsonDartModelList) {
        debugPrint(model);
        dartFiles.add(model.dartFile);
        classNames.addAll(model.classNames);
        // 拷贝xxx.g.dart文件
        final regExpFromJson = RegExp(r'([a-zA-Z0-9_$]+).fromJson');
        final safelyTypeMethodMapping = {
          'bool': '_\$safelyAsBool',
          'int': '_\$safelyAsInt',
          'double': '_\$safelyAsDouble',
          'String': '_\$safelyAsString',
        };
        final dartGFileLines = model.dartGFile.readAsLinesSync().map((line) {
          if (line.startsWith('part of')) {
            return "part of 'json_partner.dart';";
          }
          final match = regExpFromJson.firstMatch(line);
          if (match != null &&
              match.groupCount == 1 &&
              match.group(1) != null) {
            line = line.replaceAll(
                "${match.group(1)}.fromJson", "_\$${match.group(1)}FromJson");
          }
          final words = line.split(' ');
          var indexOfStart = 0;
          while (true) {
            final index = words.indexOf('as', indexOfStart++);
            if (index == -1) {
              break;
            }
            if (index > 1 && index != (words.length - 1)) {
              safelyTypeMethodMapping.forEach((type, method) {
                final prev = words[index - 1];
                final next = words[index + 1];
                if (next.startsWith('$type?')) {
                  final old = prev.contains('.parse(')
                      ? prev.split('.parse(')[1]
                      : prev;
                  line = line.replaceFirst('$old as $type?', '$method($old)');
                  return;
                } else if (next.startsWith(type)) {
                  final old = prev.contains('.parse(')
                      ? prev.split('.parse(')[1]
                      : prev;
                  line = line.replaceFirst('$old as $type', '$method($old)!');
                  return;
                }
              });
            }
          }
          return line;
        });
        io.File(path.join(
                generatedDir.path,
                model.dartGFile.parent.path.replaceAll(path.separator, '_') +
                    '_' +
                    model.dartGFile.filename))
            .also((it) => dartGFiles.add(it))
            .writeAsStringSync(dartGFileLines.join('\r\n').trim() + '\r\n');
      }
    }

    // 生成json_partner.part.dart文件
    void generateJsonPartnerPartDart() {
      io.File(path.join(generatedDir.path, 'json_partner.part.dart'))
          .writeAsStringSync('''
$CODE_HEADER
part of 'json_partner.dart';
  
dynamic _getToJson<T>(Type type, data) {
  switch (type) {
  ${classNames.map((e) => '''
  case $e:
      return _\$${e}ToJson(data);
''').join('')}
  }
  return data as T;
}

dynamic _fromJsonSingle<M>(json) {
  final type = M.toString();
  ${classNames.map((e) => '''
  if (type == ($e).toString()) {
    return _\$${e}FromJson(json);
  }
  ''').join('')}
  return null;
}

M _getListChildType<M>(List data) {
  ${classNames.map((e) => '''
  if (<$e>[] is M) {
    return data.map<$e>((e) => _\$${e}FromJson(e)).toList() as M;
  }
''').join('')}
  throw Exception('not support type');
}

${classNames.map((e) => '''
/// ${e}Factory
extension ${e}Factory on $e {
  /// fromJson
  static $e fromJson(json) => JsonPartner.fromJsonAsT<$e>(json);
  
  /// toJson
  Map<String, dynamic> toJson() => JsonPartner.toJsonByT(this);
}
''').join('\r\n').trim()}
''');
    }

    // 生成json_partner.dart文件
    void generateJsonPartnerDart() {
      io.File(path.join(generatedDir.path, 'json_partner.dart'))
          .writeAsStringSync('''
$CODE_HEADER

${dartFiles.map((e) => "import 'package:$moduleName/${e.path.replaceAll(path.separator, '/').substring(4)}';").join('\r\n')}
import 'package:json_annotation/json_annotation.dart';

${dartGFiles.map((e) => "part '${e.filename}';").join('\r\n')}
part 'json_partner.part.dart';

/// JsonPartner
mixin JsonPartner<T> {
  /// toJson
  Map<String, dynamic> toJson() => _getToJson<T>(runtimeType, this);

  /// toJsonByT
  static Map<String, dynamic> toJsonByT<M>(M m) => _getToJson<M>(m.runtimeType, m);

  /// fromJsonAsT
  static M fromJsonAsT<M>(json) => (json is List) ? _getListChildType<M>(json) : _fromJsonSingle<M>(json) as M;
}

bool? _\$safelyAsBool(value) => (value is bool) ? value : null;
int? _\$safelyAsInt(value) => (value is int) ? value : (value is num) ? value.toInt() : (value is String) ? int.tryParse(value) : int.tryParse(value?.toString() ?? '');
double? _\$safelyAsDouble(value) => (value is double) ? value : (value is num) ? value.toDouble() : (value is String) ? double.tryParse(value) : double.tryParse(value?.toString() ?? '');
String? _\$safelyAsString(value) => (value is String) ? value : value?.toString();
''');
    }

    handleDartGFile();
    generateJsonPartnerDart();
    generateJsonPartnerPartDart();
  });
  //endregion

  //region 7# 清理中间资源
  taskChain.addTask('清理中间资源', () {
    for (var model in pendingJsonDartModelList) {
      final lines = model.dartFile.readAsLinesSync();
      int partDartGFileNumber = -1;
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.startsWith('part') &&
            (line.contains("part '${model.dartGFile.filename}';") ||
                line.contains('part "${model.dartGFile.filename}";'))) {
          partDartGFileNumber = i;
        }
      }
      if (partDartGFileNumber != -1) {
        lines.removeAt(partDartGFileNumber);
      }
      model.dartFile.writeAsStringSync(lines.join('\r\n').trimRight() + '\r\n');
      model.dartGFile.deleteSync();
    }
  });
  //endregion

  taskChain.runTasks();
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

class _JsonDartModel {
  final io.File dartFile;
  final io.File dartGFile;
  final List<String> classNames;

  const _JsonDartModel({
    required this.dartFile,
    required this.dartGFile,
    required this.classNames,
  });

  @override
  String toString() {
    return 'JsonDartModel{dartFile: $dartFile, dartGFile: $dartGFile, classNames: $classNames}';
  }

  static _JsonDartModel? tryCreate(io.File file) {
    if (!file.path.endsWith('.dart')) {
      return null;
    }
    final content = file.readAsStringSync();

    if (!content.contains('package:json_annotation/json_annotation.dart')) {
      return null;
    }
    if (!content.contains('@JsonSerializable')) {
      return null;
    }
    final reg = RegExp(r'class (.+) {');
    final classNames = <String>[];
    reg.allMatches(content).forEach((e) {
      if (e.groupCount == 1) {
        classNames.add((e.group(1) as String).split(' ').first.trim());
      }
    });
    if (classNames.isEmpty) {
      return null;
    }
    final dartGFile = io.File(
        path.join(file.parent.path, file.filenameWithoutSuffix + ".g.dart"));
    return _JsonDartModel(
        dartFile: file, dartGFile: dartGFile, classNames: classNames);
  }
}
