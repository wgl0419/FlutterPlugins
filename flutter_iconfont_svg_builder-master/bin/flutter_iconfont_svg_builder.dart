import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:flutter_iconfont_svg_builder/code_template.dart';
import 'package:flutter_iconfont_svg_builder/flutter_iconpark_utils.dart';
import 'package:flutter_iconfont_svg_builder/http_client_utils.dart';
import 'package:flutter_iconfont_svg_builder/icon_model.dart';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';
import 'package:recase/recase.dart';
import 'package:yaml/yaml.dart';

typedef Future<T> AsyncFuntion<T>();

Future<T> runTask<T>(String msg, AsyncFuntion asyncFuntion) async {
  Progress progress = logger.progress(msg);
  final result = await asyncFuntion.call();
  progress.finish(showTiming: true);
  return result as T;
}

late String _packageName;
void main(List<String> args) async {
  bool verbose = args.contains('-v');
  logger = verbose ? Logger.verbose(ansi: Ansi(true)) : Logger.standard(ansi: Ansi(true));

  String pubSpecString = File('pubspec.yaml').readAsStringSync();
  YamlMap pubSpec = (loadYaml(pubSpecString) as YamlMap);
  _packageName = pubSpec['name'];
  YamlList? iconFontConfig = pubSpec['flutter_iconfont_svg_builder']['fonts'];

  if (iconFontConfig == null || iconFontConfig.isEmpty) {
    logger.error('not found svg fonts config');
    exit(-1);
  }

  if (iconFontConfig.length != iconFontConfig.map((element) => element['class-name']).toSet().length) {
    logger.error('重复的 class-name');
    exit(-1);
  }

  int index = 0;
  for (final config in iconFontConfig) {
    await _generateFontTask(config, index);
    index++;
  }

  logger.success('success');
  exit(0);
}

Future<void> _generateFontTask(config, index) async {
  var _svgSymbolUrl = config['svg-symbol'];
  final svgSymbolUrl = (_svgSymbolUrl is List ? _svgSymbolUrl.toSet().toList() : [_svgSymbolUrl]);
  final List<String> symbolContents = await runTask('开始获取svg', () async {
    return Future.wait(svgSymbolUrl.toList().map((url) => HttpClientUtils.get(url)));
  });

  List<IconModel> iconModels = [];
  await runTask('开始解析svg', () async {
    RegExp svgReg = RegExp(r'<svg>(.+?)<\/svg>');

    for (final symbolContent in symbolContents) {
      final svgString = svgReg.firstMatch(symbolContent)?.group(0);
      if (svgString == null || svgString.isEmpty) {
        logger.error('not found svg');
        exit(-1);
      }

      final svgDocument = XmlDocument.parse(svgString);

      final symbols = svgDocument.findAllElements('symbol');

      if (symbols.isEmpty) {
        logger.error('not found symbols');
        exit(-1);
      }

      for (final symbol in symbols) {
        final attributes = symbol.attributes;
        final XmlAttribute? id = attributes
            .cast<XmlAttribute?>()
            .firstWhere((element) => element?.name.toString() == 'id', orElse: () => null);

        if (id == null || id.value.isEmpty) {
          logger.error('invalid id value');
          exit(-1);
        }

        final XmlAttribute? viewBox = attributes
            .cast<XmlAttribute?>()
            .firstWhere((element) => element?.name.toString() == 'viewBox', orElse: () => null);

        if (viewBox == null || viewBox.value.isEmpty) {
          logger.error('invalid viewBox value');
          exit(-1);
        }

        List<IconPath> paths = [];
        int index = 0;
        for (var item in symbol.children) {
          String? defaultColor = item.getAttribute('fill');
          if (defaultColor != null) {
            String getColor = '''getColor($index, color, colors, '$defaultColor')''';
            StringBuffer ss = StringBuffer();
            ss.write('\${');
            ss.write(getColor);
            ss.write('}');
            item.setAttribute('fill', ss.toString());
          }
          paths.add(IconPath(defaultColor, item.toString()));
          index++;
        }
        iconModels.add(IconModel(id.value, viewBox.value, paths));
      }
    }
  });

  String _className = config['class-name'] ?? 'IconFont${index == 0 ? '' : index}';
  String dartCode = '';
  String htmlCode = '';
  await runTask('生成 Dart & html Code', () async {
    StringBuffer iconNameConstString = StringBuffer('');
    StringBuffer switchNames = StringBuffer('');
    StringBuffer iconFonts = StringBuffer('');
    List<String> iconNames = [];
    for (final iconModel in iconModels) {
      String iconName = FlutterIconParkUtils.checkIconNames(iconNames, ReCase(iconModel.name).camelCase);
      iconNames.add(iconName);
      iconNameConstString.write('''\ \ static const String ${iconName} = '${iconName}';\n''');
      String svgXml = '''
<svg viewBox="${iconModel.viewBox}" xmlns="http://www.w3.org/2000/svg">
  ${iconModel.paths.map((e) => e.path).join('\n')}
</svg>
    ''';
      switchNames.write('''
    case ${iconName}:
        return \'\'\'$svgXml\'\'\';
    ''');

      iconFonts.write('''
    <li class="dib">
        <svg class="iconpark-icon icon svg-icon" aria-hidden="true">
          <use href="#${iconModel.name}"></use>
        </svg>
        <div class="name">${iconName}</div>
    </li>
    ''');
    }
    dartCode = genDartTemplate(ReCase(_className).pascalCase, iconNameConstString.toString(), switchNames.toString());
    htmlCode = genFontDemoTemplate(_packageName, svgSymbolUrl.map((u) => '<script src="${u}"></script>').join('\n'),
        iconFonts.toString(), ReCase(_className).pascalCase);
  });

  await runTask('写入文件', () async {
    Directory dartFileDir = Directory(path.join(Directory.current.path, config['dart-file-path'] ?? 'lib/generated'));
    FlutterIconParkUtils.createDirIsNotExists(dartFileDir.path);
    FlutterIconParkUtils.writeToFile(dartCode, path.join(dartFileDir.path, '${ReCase(_className).snakeCase}.g.dart'));
    FlutterIconParkUtils.writeToFile(
        htmlCode, path.join(dartFileDir.path, '${ReCase(_className).snakeCase}.demo.html'));
  });
}
