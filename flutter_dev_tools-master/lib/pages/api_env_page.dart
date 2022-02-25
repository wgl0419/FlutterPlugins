import 'package:flutter/material.dart';
import 'package:flutter_base_kit/flutter_base_kit.dart';

class ApiEnvPage extends StatefulWidget {
  const ApiEnvPage({Key? key}) : super(key: key);

  @override
  _ApiEnvPageState createState() => _ApiEnvPageState();
}

class _ApiEnvPageState extends State<ApiEnvPage> {
  late AppEnvironments _apiEnvType;

  @override
  void initState() {
    super.initState();
    setState(() {
      _apiEnvType = AppEnv.currentEnv();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(244, 245, 246, 1),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text('Api环境'),
          centerTitle: true,
          leading: const BackButton(
            color: Colors.black,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Item(
                title: '开发环境',
                selected: _apiEnvType == AppEnvironments.dev,
                onPress: () {
                  AppEnv.changeEnv(AppEnvironments.dev);
                  setState(() {
                    _apiEnvType = AppEnvironments.dev;
                  });
                },
              ),
              Item(
                title: '测试环境',
                selected: _apiEnvType == AppEnvironments.test,
                onPress: () {
                  AppEnv.changeEnv(AppEnvironments.test);
                  setState(() {
                    _apiEnvType = AppEnvironments.test;
                  });
                },
              ),
              Item(
                title: '预发布环境',
                selected: _apiEnvType == AppEnvironments.pre,
                onPress: () {
                  AppEnv.changeEnv(AppEnvironments.pre);
                  setState(() {
                    _apiEnvType = AppEnvironments.pre;
                  });
                },
              ),
              Item(
                title: '生产环境',
                selected: _apiEnvType == AppEnvironments.prod,
                onPress: () {
                  AppEnv.changeEnv(AppEnvironments.prod);
                  setState(() {
                    _apiEnvType = AppEnvironments.prod;
                  });
                },
              ),
              Item(
                title: '自定义环境',
                selected: _apiEnvType == AppEnvironments.custom,
                onPress: () {
                  setState(() {
                    _apiEnvType = AppEnvironments.custom;
                  });
                },
              ),
              if (_apiEnvType == AppEnvironments.custom) ...{
                ElevatedButton(
                    onPressed: () async {
                      // NavigatorUtils.pushResult(context, DevToolsRouter.scanQrcodePage, (Object data) {
                      //   if (data != null) {
                      //     String text = data as String;

                      //     try {
                      //       final jsonObj = json.decode(text);
                      //       print(jsonObj);
                      //       Log.d(jsonObj.toString());

                      //       /// 检查是否合法
                      //       if (jsonObj != null && jsonObj.containsKey('host') && jsonObj.containsKey('socketIOUrl')) {
                      //         SpUtil.putObject(Constant.customApiUrlConfigCacheKey, jsonObj);
                      //         ApiEnv.changeEnv(ApiEnvType.custom);
                      //         Toast.showSuccess('请重新启动App!');
                      //         Future.delayed(const Duration(milliseconds: 200), () {
                      //           NavigatorUtils.goBack(context, num: 2);
                      //         });
                      //       } else {
                      //         Toast.showError('json字符串不合法, 请扫描正确的数据!');
                      //       }
                      //     } catch (e) {
                      //       Toast.showError('json字符串不合法, 请扫描正确的数据!');
                      //       Log.e(e.toString());
                      //     }
                      //   }
                      // });
                    },
                    child: const Text('扫码'))
              }
            ],
          ),
        ));
  }
}

class Item extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback? onPress;

  const Item({Key? key, required this.title, this.selected = false, this.onPress});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          border: Border(
            bottom: Divider.createBorderSide(context, width: 0.8),
          ),
        ),
        child: InkWell(
          onTap: onPress,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 15),
              ),
              if (selected) ...{
                const Icon(
                  Icons.radio_button_checked,
                  color: Colors.blueAccent,
                )
              } else ...{
                const Icon(
                  Icons.radio_button_off,
                  color: Colors.grey,
                )
              }
            ],
          ),
        ));
  }
}
