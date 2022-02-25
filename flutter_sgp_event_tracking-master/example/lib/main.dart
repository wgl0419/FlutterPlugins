import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sgp_event_tracking/device_info.dart';
import 'package:flutter_sgp_event_tracking/flutter_sgp_event_tracking.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    FlutterSgpEventTracking.init(
        appId: '9d56fbc7-9afe-49fd-88b3-e51160f0a62d',
        appSecret: 'dca2ad52-ebba-436a-a48c-0dde6a67fe91',
        apiHost: 'http://point-upload-dev.aitdcoin.com/api/point/v1/report');
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // try {
    //   platformVersion = await FlutterSgpEventTracking.platformVersion;
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    try {
      DeviceInfo info = await FlutterSgpEventTracking.getDeviceInfo;
      print(info);
    } catch (e) {
      print(e);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: true,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
        bottomNavigationBar: TextButton(
          child: Text('点我'),
          onPressed: () {
            FlutterSgpEventTracking.operateEvent(
                eventCode: 'okokok',
                pageCode: 'xxxooo',
                loadType: '修改密码',
                operationItems: '用户修改密码',
                eventDescription: '密码1->2');
          },
        ),
      ),
    );
  }
}
