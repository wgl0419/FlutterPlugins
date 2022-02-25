import 'package:flutter/material.dart';

/// 顶部操作组件
///
/// [title] 标题 (required)
/// [titleTextStyle] 标题样式
/// [leading] 左侧小组件
/// [trailing] 右侧小组件
class ActionSheetBar {
  final String title;
  final TextStyle? titleTextStyle;
  final String? desc;
  final TextStyle? descTextStyle;
  final Widget? cancelWidget;
  final Widget? doneWidget;
  final bool showBottomLine;
  final GestureTapCallback? cancelAction;
  final ValueChanged<List<int>>? doneAction;
  final bool showAction;

  const ActionSheetBar(this.title,
      {this.titleTextStyle,
      this.desc,
      this.descTextStyle,
      this.cancelWidget,
      this.doneAction,
      this.showBottomLine = true,
      this.showAction = true,
      this.cancelAction,
      this.doneWidget});
}
