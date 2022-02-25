import 'package:flutter/material.dart';
import 'package:flutter_base_kit/pkg/logger/logger.dart';
import 'package:flutter_base_kit/theme/gaps.dart';
import 'package:get/get.dart';

class WidgetBuilderPlus extends StatelessWidget {
  /// 设置此值后, 会自动包裹 Stack
  final RxBool? canCreate;

  /// 实际要显示的 widget
  final WidgetBuilder builder;

  /// 占位 widget
  final WidgetBuilder? holderBuilder;

  final _animationCompleted = false.obs;

  WidgetBuilderPlus({Key? key, required this.builder, this.canCreate, this.holderBuilder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var route = ModalRoute.of(context);
    if (route != null && !_animationCompleted.value) {
      void handler(status) {
        if (status == AnimationStatus.completed) {
          route.animation?.removeStatusListener(handler);
          _animationCompleted.value = true;
          logger.i('动画执行完成, 开始加载webView');
        }
      }

      route.animation?.addStatusListener(handler);
    }
    return Obx(() {
      if (!_animationCompleted.value) {
        return holderBuilder != null ? holderBuilder!(context) : Gaps.empty;
      }

      if (canCreate == null) {
        return build(context);
      } else {
        return Stack(
          children: [
            builder(context),
            Offstage(
              offstage: canCreate!.value,
              child: holderBuilder != null
                  ? holderBuilder!(context)
                  : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
              ),
            ),
          ],
        );
      }
    });
  }
}
