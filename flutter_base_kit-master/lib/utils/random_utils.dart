import 'dart:math';

import 'package:uuid/uuid.dart';

class RandomUtils {
  RandomUtils._();
  static const String _letterLowerCase = "abcdefghijklmnopqrstuvwxyz";
  static const String _letterUpperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  static const String _number = '0123456789';
  static const String _special = '@#%^*>\$@?/[]=+';

  static final Random _random = Random.secure();

  static int nextInt({int max = 6}) {
    return _random.nextInt(max);
  }

  ///  [0-9 a-z A-Z]
  static String alphanumeric({int length = 18, bool symbols = false}) {
    return _generate(length, _letterLowerCase + _letterUpperCase + _number + (symbols ? _special : ''));
  }

  ///  [a-z A-Z]
  static String alphabetic({int length = 18}) {
    return _generate(length, _letterLowerCase + _letterUpperCase);
  }

  ///  [0-9]
  static String numeric({int length = 6}) {
    return _generate(length, _number);
  }

  static String _generate(int length, String chars) {
    int _l = length;
    StringBuffer _sb = StringBuffer();
    while (_l > 0) {
      String n = chars[_random.nextInt(chars.length)];
      if (n == '0' && _l == length) {
        continue;
      }
      _sb.write(n);
      _l--;
    }
    return _sb.toString();
  }

  /// base uuid v4
  static String uniqueString() {
    return const Uuid().v4().replaceAll('-', '');
  }
}
