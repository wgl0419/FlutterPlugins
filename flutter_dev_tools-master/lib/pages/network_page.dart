import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base_kit/flutter_base_kit.dart';
import 'package:flutter_dev_tools/flutter_dev_tools.dart';
import 'package:flutter_dev_tools/routes/dev_tools_route.dart';
import 'package:get/get.dart';

class NetworkPage extends StatelessWidget {
  const NetworkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? apiHost = FlutterDevTools.dataDelegate?.apiHost;
    return Scaffold(
        backgroundColor: const Color.fromRGBO(244, 245, 246, 1),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text('网络工具'),
          centerTitle: true,
          leading: const BackButton(
            color: Colors.black,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Item(
                title: '环境管理',
                onPress: () {
                  Get.toNamed(Routes.apiEnvPage);
                },
              ),
              Item(
                title: '代理设置',
                onPress: () {
                  Get.toNamed(Routes.apiProxyPage);
                },
              ),
              Item(
                title: '网络测速',
                onPress: () {
                  Toast.showError('暂未开放');
                },
              ),
              Card(
                margin: const EdgeInsets.all(15),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [const Text('环境'), Text(AppEnv.currentEnv().value)],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [const Text('代理'), Text('${ApiProxy.apiProxy}')],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                  margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Table(
                        border: const TableBorder(
                          top: BorderSide(color: Colors.black12),
                          left: BorderSide(color: Colors.black12),
                          right: BorderSide(color: Colors.black12),
                          bottom: BorderSide(color: Colors.black12),
                          horizontalInside: BorderSide(color: Colors.black12),
                          verticalInside: BorderSide(color: Colors.black12),
                        ),
                        children: apiHost != null
                            ? apiHost.keys
                                .map((k) => TableRow(
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Text(k),
                                          ),
                                        ),
                                        TableCell(
                                          child: InkWell(
                                            child: Padding(
                                                padding: const EdgeInsets.all(5),
                                                child: Text(
                                                  apiHost[k] as String,
                                                  maxLines: 3,
                                                  overflow: TextOverflow.clip,
                                                )),
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(text: apiHost[k] as String));
                                              Toast.show('已复制到剪切板');
                                            },
                                          ),
                                        )
                                      ],
                                    ))
                                .toList()
                            : []),
                  )),
            ],
          ),
        ));
  }
}

class Item extends StatelessWidget {
  final String title;
  final VoidCallback onPress;

  const Item({Key? key, required this.title, required this.onPress}) : super(key: key);

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
            const Icon(Icons.keyboard_arrow_right)
          ],
        ),
      ),
    );
  }
}
