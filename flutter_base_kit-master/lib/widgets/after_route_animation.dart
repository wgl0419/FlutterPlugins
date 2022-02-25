import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AfterRouteAnimation extends StatefulWidget {
  const AfterRouteAnimation({Key? key, required this.builder, this.holderWidget}) : super(key: key);

  final WidgetBuilder builder;
  final Widget? holderWidget;

  @override
  _AfterRouteAnimationState createState() => _AfterRouteAnimationState();
}

class _AfterRouteAnimationState extends State<AfterRouteAnimation> {
  final animationCompleted = false.obs;

  @override
  Widget build(BuildContext context) {
    var route = ModalRoute.of(context);
    if (route != null && !animationCompleted.value) {
      void handler(status) {
        if (status == AnimationStatus.completed) {
          route.animation?.removeStatusListener(handler);
          animationCompleted.value = true;
        }
      }

      route.animation?.addStatusListener(handler);
    }

    return Obx(() {
      if (!animationCompleted.value) {
        return widget.holderWidget ?? const SizedBox();
      }
      return widget.builder(context);
    });
  }
}
