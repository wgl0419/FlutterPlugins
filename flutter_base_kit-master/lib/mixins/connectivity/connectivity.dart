import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import 'connectivity_aware.dart';

mixin ConnectivityMixin on GetxController, ConnectivityAware {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(onConnectivityChanged);
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
