import 'package:flutter/material.dart';
import 'package:flutter_base_kit/flutter_base_kit.dart';
import 'package:flutter_dev_tools/widgets/my_button.dart';
import 'package:flutter_dev_tools/widgets/my_text_field.dart';

class ApiProxyPage extends StatefulWidget {
  const ApiProxyPage({Key? key}) : super(key: key);

  @override
  _ApiProxyPageState createState() => _ApiProxyPageState();
}

class _ApiProxyPageState extends State<ApiProxyPage> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  bool _clickable = false;

  @override
  void initState() {
    super.initState();
    final String? apiProxy = ApiProxy.apiProxy;
    if (apiProxy != null && apiProxy.isNotEmpty) {
      _ipController.text = apiProxy.split(':').first;
      _portController.text = apiProxy.split(':').last;
    }
    _ipController.addListener(_verify);
    _portController.addListener(_verify);
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _verify() {
    final String ip = _ipController.text;
    final String port = _portController.text;
    final int portInt = int.parse(port);
    bool clickable = false;
    if (GetUtils.isIPv4(ip) && portInt > 0 && portInt < 65535) {
      clickable = true;
    }
    if (clickable != _clickable) {
      setState(() {
        _clickable = clickable;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(244, 245, 246, 1),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text('代理设置'),
          centerTitle: true,
          leading: const BackButton(
            color: Colors.black,
          ),
        ),
        body: SingleChildScrollView(
            child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            children: [
              MyTextField(
                controller: _ipController,
                focusNode: _nodeText1,
                maxLength: 15,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                hintText: '请输入IP地址',
                labelText: 'IP地址',
              ),
              const SizedBox(height: 8),
              MyTextField(
                controller: _portController,
                focusNode: _nodeText2,
                maxLength: 5,
                keyboardType: TextInputType.phone,
                hintText: '请输入端口号',
                labelText: '端口号',
              ),
              const SizedBox(height: 24),
              MyButton(
                onPressed: _clickable
                    ? () {
                        ApiProxy.setProxy(_ipController.text, int.parse(_portController.text));
                        Get.backWithNum(2);
                      }
                    : null,
                text: '保存',
              ),
              const SizedBox(height: 16),
              TextButton(
                  onPressed: () async {
                    await ApiProxy.resetProxy();
                    _ipController.text = '';
                    _portController.text = '';
                    setState(() {});
                  },
                  child: const Text('清空代理')),
              const SizedBox(height: 16),
              // TextButton(
              //     onPressed: () async {
              //       // NavigatorUtils.pushResult(context, DevToolsRouter.scanQrcodePage, (Object data) {
              //       //   if (data != null) {
              //       //     String proxy = data as String;
              //       //     _ipController.text = proxy.split(':').first;
              //       //     _portController.text = proxy.split(':').last;
              //       //     _verify();
              //       //   }
              //       // });
              //     },
              //     child: const Text('扫码'))
            ],
          ),
        )));
  }
}

extension NavExt on GetInterface {
  void backWithNum([int n = 1]) {
    var i = 0;
    Get.until((_) {
      ++i;
      return i == n;
    });
  }
}
