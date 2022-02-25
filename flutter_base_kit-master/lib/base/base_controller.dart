import 'package:get/get.dart';
import 'package:flutter_base_kit/mixins/connectivity/connectivity.dart';
import 'package:flutter_base_kit/mixins/connectivity/connectivity_aware.dart';

abstract class NeBaseController extends GetxController {}

abstract class NeLifeCycleController extends FullLifeCycleController
    with FullLifeCycle {}

abstract class NeFullLifeCycleController extends NeLifeCycleController
    with ConnectivityAware, ConnectivityMixin {}
