part of bk_logger;

// import 'package:stack_trace/stack_trace.dart';

Loggy<LoggyType> _logger = Loggy('Log');
Loggy<LoggyType> get logger => _logger;

extension LogExt on Loggy<LoggyType> {
  void changeName(String name) {
    _logger = Loggy(name);
  }

  void d(dynamic message, {Object? err, StackTrace? stackTrace}) => log(LogLevel.debug, message, err, stackTrace);
  void i(dynamic message, {Object? err, StackTrace? stackTrace}) => log(LogLevel.info, message, err, stackTrace);
  void w(dynamic message, {Object? err, StackTrace? stackTrace}) => log(LogLevel.warning, message, err, stackTrace);
  void e(dynamic message, {Object? err, StackTrace? stackTrace}) => log(LogLevel.error, message, err, stackTrace);
}

class LoggerFilter implements LoggyFilter {
  @override
  bool shouldLog(LogLevel level, Type type) {
    // print('${level.name}: ${type.toString()}');
    return true;
  }
}
