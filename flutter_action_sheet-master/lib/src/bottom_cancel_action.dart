import 'package:flutter/material.dart';

/// 底部取消组件
///
/// [title] 标题 (required)
/// [titleTextStyle] 标题样式
/// [onPress] 点击事件
class BottomCancelActon {
  final String title;
  final TextStyle? titleTextStyle;
  final GestureTapCallback? onPress;

  const BottomCancelActon(this.title, {this.titleTextStyle, this.onPress});
}
