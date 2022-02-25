import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qrscan_plugin/flutter_qrscan_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Permission.camera.request().then((value) => null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        body: Center(
          child: Builder(builder: (context) {
            return SizedBox(
              height: 350,
              child: QrScanView(
                primaryColor: Colors.blueAccent,
                onFiller: (results) => results,
                onResult: (result, source, disposable) async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: Text(result == null ? '扫描失败' : '扫描成功'),
                        content: Text(result?.text ?? '没有发现二维码'),
                        actions: <Widget>[
                          TextButton(
                            child: Text(result != null ? '拷贝' : '确定'),
                            onPressed: () {
                              if (result != null) {
                                Clipboard.setData(
                                  ClipboardData(text: result.text),
                                );
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  disposable.rescan();
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
