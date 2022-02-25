import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

const defaultDuration = Duration(seconds: 2);

typedef ToastCancelFunc = void Function();

/// Toast工具类
class Toast {
  static Widget? _loadingWidget;

  /// 配置loading
  static void configLoading({Widget? loadingWidget}) {
    _loadingWidget = loadingWidget;
  }

  /// 通用 Toast
  ///
  /// [msg] 提示信息
  /// [duration] 持续时间, 默认为2s
  static void show(String msg, {Duration duration = defaultDuration}) {
    BotToast.showText(text: msg, duration: duration);
  }

  /// 成功提示
  ///
  /// [msg] 提示信息
  /// [duration] 持续时间, 默认为2s
  /// [icon] 图标
  static void showSuccess(String msg,
      {Duration duration = defaultDuration,
      Icon icon = const Icon(
        Icons.done,
        color: Colors.white,
      )}) {
    showInfo(msg, icon: icon, duration: duration);
  }

  /// 失败提示
  ///
  /// [msg] 提示信息
  /// [duration] 持续时间, 默认为2s
  /// [icon] 图标
  static void showError(String msg,
      {Duration duration = defaultDuration,
      Icon icon = const Icon(
        Icons.block,
        color: Colors.white,
      )}) {
    showInfo(msg, icon: icon, duration: duration);
  }

  /// 信息提示
  ///
  /// [msg] 提示信息
  /// [duration] 持续时间, 默认为2s
  /// [icon] 图标
  static void showInfo(String msg,
      {Duration duration = defaultDuration,
      Icon icon = const Icon(
        Icons.info,
        color: Colors.white,
      )}) {
    showCustomText(
        msg: msg,
        indicator: StatusWidget(
          icon: icon,
          msg: msg,
        ),
        duration: duration);
  }

  /// 显示自定义文本提示
  ///
  /// [msg] 消息提示
  /// [duration] 持续时间, 默认2s
  /// [indicator] 自定义组件
  static void showCustomText({String? msg, required Widget indicator, Duration duration = defaultDuration}) {
    BotToast.showCustomText(
        align: Alignment.center,
        enableKeyboardSafeArea: true,
        clickClose: false,
        crossPage: true,
        ignoreContentClick: true,
        duration: duration,
        backgroundColor: Colors.transparent,
        toastBuilder: (_) => indicator);
  }

  /// 显示Loading
  ///
  /// [enableKeyboardSafeArea] 是否启用键盘安全区,防止键盘挡住Toast
  /// [crossPage] 跨页面显示,如果为true,则该Toast会跨越多个Route显示,
  /// 如果为false则在当前Route发生变化时,会自动关闭该Toast,例如[Navigator.push]-[Navigator.pop]
  /// [ignoreContentClick] 是否忽视ToastContext区域
  /// 这个参数如果为true时,用户点击该ToastContext区域时,用户可以的点击事件可以正常到达到Page上
  /// 换一句话说就是透明的(即便是Toast背景颜色不是透明),如果为false,则情况反之
  static ToastCancelFunc showLoading({
    bool enableKeyboardSafeArea = true,
    bool crossPage = false,
    bool ignoreContentClick = true,
  }) {
    return BotToast.showCustomLoading(
        align: Alignment.center,
        enableKeyboardSafeArea: enableKeyboardSafeArea,
        clickClose: false,
        crossPage: crossPage,
        ignoreContentClick: true,
        backgroundColor: Colors.transparent,
        toastBuilder: (_) =>
            _loadingWidget ??
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: Colors.black87),
              height: 55,
              width: 55,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ));
  }

  static void hideLoading() {
    BotToast.closeAllLoading();
  }

  /// 隐藏 Toast
  static void cancelToast() {
    dismiss();
  }

  static void dismiss() {
    BotToast.cleanAll();
  }
}

class StatusWidget extends StatelessWidget {
  final Icon icon;
  final String msg;

  const StatusWidget({Key? key, required this.icon, required this.msg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(
            height: 10,
          ),
          Text(
            msg,
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }
}
