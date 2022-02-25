import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityAware {
  void onConnectivityChanged(ConnectivityResult result);
}
