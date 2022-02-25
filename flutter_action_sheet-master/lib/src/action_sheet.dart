import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_action_sheet/flutter_action_sheet.dart';
import 'package:flutter_action_sheet/src/action_sheet_bar.dart';
import 'package:flutter_action_sheet/src/action_sheet_item.dart';

import 'bottom_cancel_action.dart';

typedef SelectWidgetBuilder = Widget Function(BuildContext context, int index, bool selected);

/// 通用ActionSheet
///
/// [context] this is [BuildContext]
/// [actionSheetBar] 顶部组件
/// [actions] 中间组件
/// [selections] 单选/多选组件
/// [selectedWidget] 选中组件
/// [unSelectedWidget] 反选组件
/// [selectWidgetBuilder] 选择组件builder
/// [itemHeight] 每行高度
/// [mutiple] 是否多选
/// [maxSelected] 最多选择数量, -1 不限制
/// [content] 自定义中间内容
/// [paddingBottom] 用于自定义内容底部内边距
/// [bottomAction] 底部按钮
/// [barrierColor] 遮罩颜色, 不能为透明色
/// [actionSheetColor] 组件的背景颜色
/// [isScrollControlled] 是否时全屏还是半屏
/// [isDismissible] 点击背景是否可以关闭
/// [enableDrag] 是否允许拖拽
///
Future<T?> showActionSheet<T>({
  required BuildContext context,
  ActionSheetBar? actionSheetBar,
  List<ActionSheetItem>? actions,
  List<ActionSheetSelectItem>? selections,
  Widget? selectedWidget,
  Widget? unSelectedWidget,
  SelectWidgetBuilder? selectWidgetBuilder,
  double itemHeight = 50,
  bool mutiple = false,
  int maxSelected = -1,
  Widget? content,
  double? paddingBottom,
  BottomCancelActon? bottomAction,
  Color? barrierColor,
  Color? actionSheetColor,
  bool isScrollControlled = false,
  bool isDismissible = true,
  bool enableDrag = true,
}) async {
  assert(barrierColor != Colors.transparent, 'The barrier color cannot be transparent.');
  // 当有头部并且有标题的时候, 设置顶部圆角
  final roundedRectangleBorder = actionSheetBar == null
      ? null
      : const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ));

  return showModalBottomSheet<T>(
      context: context,
      elevation: 0,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: actionSheetColor ?? Theme.of(context).dialogBackgroundColor,
      barrierColor: barrierColor,
      shape: roundedRectangleBorder,
      builder: (ctx) {
        return ActionSheet(
            actionSheetBar: actionSheetBar,
            actions: actions,
            selections: selections,
            selectedWidget: selectedWidget,
            unSelectedWidget: unSelectedWidget,
            selectWidgetBuilder: selectWidgetBuilder,
            itemHeight: itemHeight,
            maxSelected: maxSelected,
            mutiple: mutiple,
            content: content,
            paddingBottom: paddingBottom,
            bottomAction: bottomAction);
      });
}

class ActionSheet extends StatefulWidget {
  const ActionSheet(
      {Key? key,
      this.actionSheetBar,
      this.actions,
      this.selections,
      required this.mutiple,
      this.content,
      this.paddingBottom,
      this.bottomAction,
      this.selectedWidget,
      this.unSelectedWidget,
      required this.itemHeight,
      required this.maxSelected,
      this.selectWidgetBuilder})
      : super(key: key);

  final ActionSheetBar? actionSheetBar;
  final List<ActionSheetItem>? actions;
  final List<ActionSheetSelectItem>? selections;
  final bool mutiple;
  final Widget? selectedWidget;
  final Widget? unSelectedWidget;
  final double itemHeight;
  final SelectWidgetBuilder? selectWidgetBuilder;
  final int maxSelected;
  final Widget? content;
  final double? paddingBottom;
  final BottomCancelActon? bottomAction;

  @override
  _ActionSheetState createState() => _ActionSheetState();
}

class _ActionSheetState extends State<ActionSheet> {
  List<int> selectedIndex = [];
  StreamController<List<int>>? _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    selectedIndex = [];
    _controller?.close();
    super.dispose();
  }

  List<Widget> _buildActionBar() {
    final List<Widget> widgets = [];
    final ActionSheetBar? actionSheetBar = widget.actionSheetBar;

    if (widget.actionSheetBar != null) {
      widgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (actionSheetBar!.showAction) ...{
            actionSheetBar.cancelWidget ??
                IconButton(
                    splashColor: Colors.transparent,
                    icon: const Icon(
                      Icons.close,
                    ),
                    onPressed: () {
                      if (actionSheetBar.cancelAction != null) {
                        actionSheetBar.cancelAction!();
                      } else {
                        Navigator.pop(context);
                      }
                    }),
          },
          actionSheetBar.title.isEmpty
              ? SizedBox()
              : Expanded(
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 50,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          actionSheetBar.title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                              .merge(actionSheetBar.titleTextStyle),
                          textAlign: TextAlign.center,
                        ),
                      ))),
          if (actionSheetBar.showAction) ...{
            actionSheetBar.doneWidget ??
                IconButton(
                    splashColor: Colors.transparent,
                    icon: const Icon(
                      Icons.done,
                      // size: 18,
                    ),
                    onPressed: () {
                      if (actionSheetBar.doneAction != null) {
                        actionSheetBar.doneAction!(selectedIndex);
                      } else {
                        Navigator.pop(context);
                      }
                    }),
          },
        ],
      ));
    }

    if (widget.actionSheetBar?.desc != null) {
      widgets.add(Row(
        children: [
          Expanded(
              child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(
                    actionSheetBar!.desc!,
                    style: const TextStyle(color: Colors.black45, fontSize: 12).merge(actionSheetBar.descTextStyle),
                    textAlign: TextAlign.center,
                  )))
        ],
      ));
    }

    if (widget.actionSheetBar?.showBottomLine == true) {
      widgets.add(const Divider(
        height: 1,
      ));
    }
    return widgets;
  }

  Widget _buildBody() {
    final List<Widget> widgets = [];

    if (widget.actions != null && widget.actions!.length > 0) {
      widget.actions!.forEach((action) {
        final index = widget.actions!.indexOf(action);
        widgets.add(Container(
          width: double.infinity,
          child: InkWell(
            highlightColor: Colors.white60,
            splashFactory: NoSplash.splashFactory,
            onTap: () {
              if (action.onPress != null) {
                action.onPress!();
              } else {
                Navigator.pop(context);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                action.title,
                style: const TextStyle(
                  fontSize: 14,
                ).merge(action.titleTextStyle),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ));
        if (index < widget.actions!.length - 1) {
          widgets.add(const Divider(
            height: 0,
          ));
        }
      });
    }

    if (widget.selections != null) {
      _controller = StreamController<List<int>>();
      widget.selections!.forEach((element) {
        if (element.isSelected) {
          final index = widget.selections!.indexOf(element);
          if (!widget.mutiple && selectedIndex.length > 0) {
            return;
          }
          selectedIndex.add(index);
          _controller?.sink.add(selectedIndex);
        }
      });
      widgets.add(Container(
        width: double.infinity,
        height: widget.selections!.length * widget.itemHeight,
        child: StreamBuilder(
          stream: _controller!.stream,
          // initialData: initialData,
          builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
            // snapshot.data
            return ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final action = widget.selections![index];
                  return Container(
                    width: double.infinity,
                    child: InkWell(
                      highlightColor: Colors.white60,
                      splashFactory: NoSplash.splashFactory,
                      onTap: action.disable
                          ? null
                          : () {
                              if (!widget.mutiple && selectedIndex[0] == index) {
                                return;
                              }
                              if (selectedIndex.contains(index)) {
                                selectedIndex.remove(index);
                              } else {
                                if (!widget.mutiple && selectedIndex.length > 0) {
                                  selectedIndex.clear();
                                }
                                if (selectedIndex.length >= widget.maxSelected && widget.maxSelected != -1) {
                                  return;
                                }
                                selectedIndex.add(index);
                              }
                              _controller?.sink.add(selectedIndex);
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: widget.selectWidgetBuilder != null
                            ? widget.selectWidgetBuilder!(
                                context, index, snapshot.hasData ? snapshot.data!.contains(index) : false)
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                // mainAxisAlignment: widget.mainAxisAlignment,
                                children: [
                                  if (action.leading != null)
                                    action.leading!
                                  else
                                    const SizedBox(
                                      height: 0,
                                      width: 0,
                                    ),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 10),
                                    child: Text(
                                      action.title,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ).merge(action.titleTextStyle),
                                    ),
                                  )),
                                  if (snapshot.hasData) ...{
                                    if (widget.selectedWidget != null) ...{
                                      snapshot.data!.contains(index)
                                          ? widget.selectedWidget!
                                          : (widget.unSelectedWidget != null)
                                              ? widget.unSelectedWidget!
                                              : SizedBox()
                                    } else
                                      Icon(Icons.check_box,
                                          color:
                                              snapshot.data!.contains(index) ? Colors.blueAccent : Colors.transparent),
                                  }
                                ],
                              ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                  );
                },
                itemCount: widget.selections!.length);
          },
        ),
      ));
    }

    return Container(
        child: Column(
      children: [
        ...widgets,
      ],
    ));
  }

  Widget _buildBottomWidget() {
    if (widget.bottomAction != null) {
      return Column(
        children: [
          Container(
            height: 10,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromRGBO(247, 248, 250, 1)
                : const Color.fromRGBO(247, 248, 250, 1),
          ),
          InkWell(
            highlightColor: Colors.white60,
            splashFactory: NoSplash.splashFactory,
            onTap: widget.bottomAction?.onPress ?? () => Navigator.of(context).pop(),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.bottomAction!.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)
                      .merge(widget.bottomAction?.titleTextStyle),
                ),
              ),
            ),
          )
        ],
      );
    }
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight - (screenHeight / 10),
        ),
        child: AnimatedPadding(
          // padding: MediaQuery.of(context).viewInsets,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  (widget.paddingBottom != null ? widget.paddingBottom! : 0)),
          duration: const Duration(milliseconds: 275),
          curve: Curves.easeOutQuad,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
            ..._buildActionBar(),
            Flexible(
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  if (widget.content != null) ...{widget.content!} else _buildBody(),
                ],
              )),
            ),
            _buildBottomWidget(),
          ]),
        ),
      ),
    );
  }
}
