import 'dart:io';

import 'package:flutter_iconfont_builder/font_config.dart';
import 'package:flutter_iconfont_builder/font_model.dart';
import 'package:flutter_iconfont_builder/http_client_utils.dart';
import 'package:flutter_iconfont_builder/iconfont_utils.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:path/path.dart' as path;

typedef Future<T> AsyncFuntion<T>();

Future<T> runTask<T>(String msg, AsyncFuntion asyncFuntion) async {
  Progress progress = logger.progress(msg);
  final result = await asyncFuntion.call();
  progress.finish(showTiming: true);
  return result as T;
}

late Logger logger;
void main(List<String> args) async {
  bool verbose = args.contains('-v');
  logger = verbose ? Logger.verbose(ansi: Ansi(true)) : Logger.standard(ansi: Ansi(true));
  fontConfig.load();

  if (fontConfig.iconFontConfig == null || fontConfig.fonts?.length == 0) {
    logger.stderr('${logger.ansi.yellow}warring: 未找到Font配置项${logger.ansi.none}');
    exit(-1);
  }

  int index = 0;
  for (final config in fontConfig.fonts!) {
    await _generateFontTask(config, index);
    index++;
  }
  exit(0);
}

Future<void> _generateFontTask(iconFontConfig, int index) async {
  final fontFamily = iconFontConfig['font-family'];
  final cssUrls = iconFontConfig['css'];
  logger.stdout('开始处理字体: [${fontFamily}]');
  if (fontFamily == null || fontFamily.isEmpty || cssUrls == null || cssUrls.isEmpty) {
    logger.stderr('${logger.ansi.red}error: 请检查配置项!${logger.ansi.none}');
    exit(-1);
  }

  final List<String> csses = await runTask('[1/5] 加载css文件内容', () async {
    final _urls = cssUrls is List ? cssUrls.toSet().toList() : [cssUrls];
    return Future.wait(_urls.map((url) => HttpClientUtils.get(url)));
  });

  await runTask('[2/5] 下载ttf字体包', () async {
    String fontRelativeDir = fontConfig.fontRelativeDir;
    List<String> fontRelativePaths = [];
    int i = 0;
    for (var css in csses) {
      final ttfFontUrl = IconFontUtils.getFontDownloadUrl(css);
      logger.trace('font url: $ttfFontUrl');
      Directory fontAbsoluteDir = Directory(path.join(Directory.current.path, fontRelativeDir));
      createDirIsNotExists(fontAbsoluteDir.path);
      String ttfFileName = '${fontFamily}${i > 0 ? i : ''}.ttf';
      fontRelativePaths.add(path.join(fontRelativeDir, ttfFileName));
      String ttfFilePath = path.join(fontAbsoluteDir.path, ttfFileName);
      logger.trace('font path: ${ttfFilePath}');
      final download = await HttpClientUtils.download(ttfFontUrl, ttfFilePath);
      if (!download) {
        logger.stderr('ttf字体包下载失败!');
        exit(-1);
      }
      i++;
    }
    IconFontUtils.writeFontConfigToYaml(fontFamily, fontRelativePaths);
  });

  List<String?> iconNames = [];
  List<String?> iconValues = [];
  await runTask('[3/5] 解析css文件内容', () async {
    for (var css in csses) {
      iconNames.addAll(IconFontUtils.getIconNames(css));
      iconValues.addAll(IconFontUtils.getIconValues(css));
    }
    iconNames = iconNames.toSet().toList();
    iconValues = iconValues.toSet().toList();
  });

  if (iconNames.isEmpty || iconNames.length != iconValues.length) {
    logger.stderr('css文件解析错误!');
    exit(-1);
  }

  final fontModels = iconNames
      .map((name) => FontModel(familyName: fontFamily, name: name!, value: iconValues[iconNames.indexOf(name)]!))
      .toList();

  final _urls = cssUrls is List ? cssUrls.toSet().toList() : [cssUrls];
  if (fontConfig.mergeDartFile == null || index + 1 == fontConfig.fonts?.length) {
    final String className = 'icon-font';
    IconFontUtils.models.addAll(fontModels);
    await runTask('[4/5] 转换为DartCode', () async {
      String dartCode = IconFontUtils.buildIconToDartCode(IconFontUtils.models, className);
      Directory dartCodeDir = Directory(path.join(Directory.current.path, fontConfig.dartRelativeDir));
      createDirIsNotExists(dartCodeDir.path);
      String fileName =
          fontConfig.mergeDartFile != null ? '${fontConfig.mergeDartFile}.g.dart' : '${fontFamily}.g.dart';
      String dartCodePath = path.join(dartCodeDir.path, fileName);
      logger.trace('dart code path: ${dartCodePath}');
      IconFontUtils.writeToFile(dartCode, dartCodePath);
    });

    IconFontUtils.cssNames.addAll(_urls.map((e) => path.basenameWithoutExtension(e)));
    await runTask('[5/5] 生成html格式文档', () async {
      String htmlCode = IconFontUtils.buildIconToHtmlCode(IconFontUtils.models, IconFontUtils.cssNames, className);
      Directory htmlCodeDir = Directory(path.join(Directory.current.path, fontConfig.htmlRelativeDir));
      createDirIsNotExists(htmlCodeDir.path);
      String fileName =
          fontConfig.mergeDartFile != null ? '${fontConfig.mergeDartFile}.doc.html' : '${fontFamily}.doc.html';
      String htmlCodePath = path.join(htmlCodeDir.path, fileName);
      logger.trace('html code dir: ${htmlCodePath}');
      IconFontUtils.writeToFile(htmlCode, htmlCodePath);
    });
  } else {
    IconFontUtils.models.addAll(fontModels);
    IconFontUtils.cssNames.addAll(_urls.map((e) => path.basenameWithoutExtension(e)));
  }
}

Directory createDirIsNotExists(String dir) {
  final _path = Directory(dir);
  if (!_path.existsSync()) {
    _path.createSync(recursive: true);
  }
  return _path;
}
