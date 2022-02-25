import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_turui_ocr/flutter_turui_ocr.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _ocrInfo;
  File? imagePath;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin Turui OCR app'),
        ),
        body: Center(
          child: Column(
            children: [
              if (imagePath != null) ...{
                Image.file(imagePath ?? File('')),
              },
              SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  await FlutterTuruiOcr.initSdk();
                },
                child: Text('初始化SDK'),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  OCRResultInfo resultInfo = await FlutterTuruiOcr.identify();
                  print('resultInfo: $resultInfo');
                  setState(() {
                    imagePath = resultInfo.frontCardInfo?.headImage ?? (resultInfo.backCardInfo?.image ?? File(''));
                    // _ocrInfo = resultInfo.toString();
                  });
                },
                child: Text('识别'),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  FlutterTuruiOcr.deInitSdk();
                },
                child: Text('反初始化SDK'),
              ),
              Text('Running on: $_ocrInfo\n')
            ],
          ),
        ),
      ),
    );
  }
}
