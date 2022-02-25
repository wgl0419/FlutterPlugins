import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_aimall_face_recognition/flutter_aimall_face_recognition.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File imageFile;
  String resInfo = '';
  String imagePath = '';

  File _idCardFile = null;

  LivingSamplingResponse _livingSamplingResponse = null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      initImosdk();
    });
  }

  void initImosdk() {
    if (Platform.isAndroid) {
      FlutterAimallFaceRecognition.initImoSDK("04C2BEA076D0296A", "JP");
    } else {
      FlutterAimallFaceRecognition.initImoSDK("9761F6A57FD0E643", "JP");
    }
  }

  void actionLiving() async {
    File file = await FlutterAimallFaceRecognition.actionLiving();
    setState(() {
      imageFile = file;
    });

    /// 清除缓存目录
    await FlutterAimallFaceRecognition.cleanCache();
    print("文件是否存在: ${file.existsSync()}");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              RaisedButton(
                onPressed: initImosdk,
                child: Text('初始化sdk'),
              ),
              RaisedButton(
                onPressed: () async {
                  SilentLivingResponse res = await FlutterAimallFaceRecognition.silentLiving(userName: "15110030400");
                  setState(() {
                    resInfo = res.toString();
                    imagePath = res.image.path;
                  });
                },
                child: Text('静默活体'),
              ),
              RaisedButton(
                onPressed: () async {
                  await FlutterAimallFaceRecognition.saveFaceToLocal(
                      "111", "simman@foxmail.com", "15110030400", "38jfaksjf20jasf", imagePath);
                },
                child: Text("保存人脸信息到本地"),
              ),
              RaisedButton(
                onPressed: () async {
                  await FlutterAimallFaceRecognition.deleteFaceToken("38jfaksjf20jasf");
                },
                child: Text("删除人脸信息"),
              ),
              RaisedButton(
                onPressed: actionLiving,
                child: Text('动作活体'),
              ),
              RaisedButton(
                onPressed: () async {
                  LivingSamplingResponse res = await FlutterAimallFaceRecognition.livingSampling();
                  _livingSamplingResponse = res;
                  setState(() {
                    resInfo = res.toString();
                  });
                },
                child: Text('实名认证活体采集'),
              ),
              RaisedButton(
                onPressed: () async {
                  // double score = await FlutterAimallFaceRecognition.faceSimilarityComparison(_idCardFile.path, [
                  //   _livingSamplingResponse.image1.path,
                  //   _livingSamplingResponse.image2.path,
                  //   _livingSamplingResponse.image3.path
                  // ]);
                  double score = await FlutterAimallFaceRecognition.faceSimilarityComparison("", []);
                  setState(() {
                    resInfo = "$score";
                  });
                },
                child: Text("图片比对"),
              ),
              RaisedButton(
                onPressed: () async {
                  CardResponse response = await FlutterAimallFaceRecognition.takeCardImage(isFront: true);
                  setState(() {
                    resInfo = response.toString();
                    imageFile = response.image;
                    _idCardFile = response.headImage;
                  });
                },
                child: Text("拍照card"),
              ),
              Text(resInfo),
              if (imageFile != null) ...{
                Image.file(
                  imageFile,
                  width: 100,
                  height: 100,
                )
              }
            ],
          ),
        ),
      ),
    );
  }
}
