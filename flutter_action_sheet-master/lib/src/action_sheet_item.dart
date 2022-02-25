import 'package:flutter/material.dart';

/// item小组件
///
/// [title] 标题 (required)
/// [titleTextStyle] 标题样式
/// [leading] 左侧小组件
/// [trailing] 右侧小组件
/// [onPress] 点击事件
class ActionSheetItem {
  final String title;
  final Widget? leading;
  final TextStyle? titleTextStyle;
  final Widget? trailing;
  final GestureTapCallback? onPress;

  const ActionSheetItem(this.title, {this.leading, this.titleTextStyle, this.trailing, this.onPress});
}
