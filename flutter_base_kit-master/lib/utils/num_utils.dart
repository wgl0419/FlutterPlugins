import 'package:decimal/decimal.dart';

class NumUtils {
  NumUtils._();
}

extension DecimalNum on num {
  Decimal get bn => Decimal.parse(toString());
}

extension DecimalString on String {
  Decimal get bn => Decimal.parse(this);
}

extension Edecimal on Decimal {
  /// 1. 整数位数
  /// 2. 小数位数
  /// 3. 整数补0
  /// 4. 小数尾补0
  /// 5. 四舍五入
  String toFixed(int precision, {bool isPad = false, bool round = true}) {
    if (precision == 0) {
      return toStringAsFixed(0);
    }
    final isDecimal = !isInteger;
    String newDecimal = precision > 0 && isPad ? '.' : '';
    if (isDecimal) {
      final decimal = toString().split('.').last;
      newDecimal = '.${decimal.substring(0, decimal.length > precision ? precision : decimal.length)}';
    }

    if (isPad) {
      newDecimal = newDecimal.padRight(precision + 1, '0');
    } else {
      newDecimal = newDecimal.endsWith('0') ? '' : newDecimal;
    }

    return '${toInt().toString()}$newDecimal';
  }
}
