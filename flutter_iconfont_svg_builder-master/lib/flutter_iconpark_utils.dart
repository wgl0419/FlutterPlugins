import 'dart:io';
import 'dart:math';
import 'package:cli_util/cli_logging.dart';

late Logger logger;

class FlutterIconParkUtils {
  static checkIconNames(List<String> names, String name) {
    if (names.contains(name)) {
      return checkIconNames(names, '${name}${Random().nextInt(1000)}');
    }
    return name;
  }

  static bool writeToFile(String content, String path) {
    File(path).writeAsStringSync(content, flush: true);
    return true;
  }

  static Directory createDirIsNotExists(String dir) {
    final _path = Directory(dir);
    if (!_path.existsSync()) {
      _path.createSync(recursive: true);
    }
    return _path;
  }
}

extension LoggerPrint on Logger {
  void log(String message) {
    logger.stdout(message);
  }

  void success(String message) {
    logger.stdout('${logger.ansi.green}$message${logger.ansi.none}');
  }

  void error(String message) {
    logger.stdout('${logger.ansi.red}error: $message${logger.ansi.none}');
  }

  void waring(String message) {
    logger.stdout('${logger.ansi.yellow}warring: $message${logger.ansi.none}');
  }
}
