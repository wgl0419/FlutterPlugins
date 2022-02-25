import 'package:flutter/material.dart';
import 'package:flutter_base_kit/utils/random_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('random utils', () {
    for (int i = 0; i < 10; i++) {
      debugPrint(RandomUtils.alphabetic());
      // print(RandomUtils.nextString(length: 6));
    }
  });
}
