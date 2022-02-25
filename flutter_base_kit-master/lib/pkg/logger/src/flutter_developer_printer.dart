part of bk_logger;

/// FlutterDeveloperPrinter that uses developer.log to show log messages
class FlutterDeveloperPrinter extends LoggyPrinter {
  const FlutterDeveloperPrinter();

  static final Map<LogLevel, String> _levelPrefixes = <LogLevel, String>{
    LogLevel.debug: '🐛 ',
    LogLevel.info: '👻 ',
    LogLevel.warning: '⚠️ ',
    LogLevel.error: '‼️ ',
  };

  // For undefined log levels
  // static const String _defaultPrefix = '🤔 ';

  @override
  void onLog(LogRecord record) {
    final String _time = record.time.toIso8601String().split('T')[1];
    // final String _callerFrame = record.callerFrame == null ? '-' : '(${record.callerFrame!.location})';
    final String _logLevel = record.level.toString().replaceAll('Level.', '').substring(0, 1).toUpperCase();

    // final String _prefix = levelPrefix(record.level) ?? _defaultPrefix;

    // final chain = Chain.forTrace(StackTrace.current);
    // final frames = chain.toTrace().frames;
    // print('-------------------------------------------> \n');
    // final lastFramex = frames.firstWhere((v) {
    //   return !v.library.startsWith('dart:') &&
    //       v.package != 'loggy' &&
    //       v.package != 'fk_logs' &&
    //       v.package != 'fk_logs_dio';
    // });
    // print(record.callerFrame);
    // print('-------------------------------------------> \n');

    // '$_prefix$_time $_logLevel $_callerFrame ${record.message}',
    final lastFrame = record.callerFrame;

    String lineAndColumn = '(${lastFrame?.line}:${lastFrame?.column}): ';
    String? member = lastFrame?.member;
    if (member == '_getxLogWriter') {
      member = member?.replaceAll('_getxLogWriter', 'GetX');
      lineAndColumn = ': ';
    } else if (member?.contains(RegExp(r'^LoggyDioInterceptor.*')) == true) {
      member = member?.replaceAll(RegExp(r'^LoggyDioInterceptor.*'), '');
      lineAndColumn = '';
    }
    String message = '$_time [$_logLevel] $member$lineAndColumn${record.message}';
    developer.log(
      message,
      name: record.loggerName,
      error: record.error,
      stackTrace: record.stackTrace,
      level: record.level.priority,
      time: record.time,
      zone: record.zone,
      sequenceNumber: record.sequenceNumber,
    );
  }

  /// Get prefix for level
  String? levelPrefix(LogLevel level) {
    return _levelPrefixes[level];
  }
}
