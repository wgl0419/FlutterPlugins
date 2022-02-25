import 'package:flutter/material.dart';

/// item select 小组件
///
/// [title] 标题 (required)
/// [titleTextStyle] 标题样式
/// [leading] 左侧小组件
/// [isSelected] 选中, 默认为 [false]
class ActionSheetSelectItem {
  final String title;
  final Widget? leading;
  final TextStyle? titleTextStyle;
  final bool isSelected;
  final bool disable;

  const ActionSheetSelectItem(this.title,
      {this.leading, this.titleTextStyle, this.isSelected = false, this.disable = false});
}
