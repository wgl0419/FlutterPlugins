// 警告: 这些代码 i18n_runner 自动生成的， 不要修改！不要修改！不要修改！
// WARN: DO NOT EDIT, THIS IS CODE GENERATED.

// ignore_for_file: prefer_single_quotes
// ignore: constant_identifier_names

import 'package:get/get.dart';

abstract class I18nKeys {
  /// 我是描述
  /// Use [I18nKeys.desc].
  static String get desc => "desc".tr;

  /// "我是描述2$
  /// Use [I18nKeys.desc2].
  static String get desc2 => "desc2".tr;
}

abstract class I18nRawKeys {
  /// 我是描述
  /// Use [I18nRawKeys.desc.tr] or [I18nRawKeys.desc.trPlaceholder([...])].
  static String get desc => "desc";

  /// "我是描述2$
  /// Use [I18nRawKeys.desc2.tr] or [I18nRawKeys.desc2.trPlaceholder([...])].
  static String get desc2 => "desc2";
}

extension I18nRawKeysExtensions on String {
  /// 支持替换占位符
  String trPlaceholder([List<String> args = const []]) {
    var key = tr;
    if (args.isNotEmpty) {
      for (final arg in args) {
        key = key.replaceFirst(RegExp(r'{}'), arg.toString());
      }
    }
    return key;
  }
}
