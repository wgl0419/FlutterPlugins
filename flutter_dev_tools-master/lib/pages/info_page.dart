import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base_kit/flutter_base_kit.dart';
import 'package:flutter_dev_tools/flutter_dev_tools.dart';
import 'package:flutter_dev_tools/widgets/skeleton.dart';
import 'package:flutter_device_udid/flutter_device_udid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sticky_headers/sticky_headers.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final List<String> _headers = ['手机信息', 'App信息', '权限信息'];
  List<List<Item>> items = [];

  final Completer<bool> _controller = Completer<bool>();

  static final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final List<NetworkInterface> interfaces =
          await NetworkInterface.list(includeLoopback: false, type: InternetAddressType.any);
      final NetworkInterface interface = interfaces.first;

      final List<InternetAddress> ipv4s =
          interface.addresses.where((element) => element.type == InternetAddressType.IPv4).toList();
      final List<InternetAddress> ipv6s =
          interface.addresses.where((element) => element.type == InternetAddressType.IPv6).toList();

      final String ipv4 = ipv4s.first.address;
      final String ipv6 = ipv6s.first.address;

      List<Item> deviceInfo = [];
      if (Platform.isAndroid) {
        deviceInfo = await _getAndroidInfo();
      } else if (Platform.isIOS) {
        deviceInfo = await _getIOSInfo();
      }

      final ConnectivityResult connectivityResult = await _connectivity.checkConnectivity();
      deviceInfo.addAll([
        Item(title: '屏幕尺寸', value: '${Get.width.toStringAsFixed(0)}x${Get.height.toStringAsFixed(0)}'),
        Item(title: '联网方式', value: connectivityResult.value),
        Item(title: 'ipv4', value: ipv4),
        Item(title: 'ipv6', value: ipv6),
        Item(title: '设备唯一标识', value: await FlutterDeviceUdid.udid),
      ]);

      items.clear();

      final appInfoData = FlutterDevTools.dataDelegate?.data;
      items.addAll([
        deviceInfo,
        [
          Item(title: '包名', value: packageInfo.packageName),
          Item(title: '版本', value: packageInfo.version),
          Item(title: '编译版本', value: packageInfo.buildNumber.toString()),
          if (appInfoData != null) ...{...appInfoData.map((e) => Item(title: e['title'], value: e['value'])).toList()},
        ],
        await _getPermission()
      ]);

      Future.delayed(const Duration(seconds: 1), () {
        _controller.complete(true);
      });
    });
  }

  Future<List<Item>> _getIOSInfo() async {
    final IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    return [
      Item(title: '设备名称', value: iosDeviceInfo.name ?? '未知'),
      Item(title: '手机型号', value: iosDeviceInfo.model ?? '未知'),
      Item(title: '系统名称', value: iosDeviceInfo.systemName ?? '未知'),
      Item(title: '系统版本', value: iosDeviceInfo.systemVersion ?? '未知'),
    ];
  }

  Future<List<Item>> _getAndroidInfo() async {
    final AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    return [
      Item(title: '设备名称', value: 'Android'),
      Item(title: '手机型号', value: androidDeviceInfo.model ?? '未知'),
      Item(title: 'Android版本', value: androidDeviceInfo.version.release ?? '未知'),
      Item(title: '系统版本', value: androidDeviceInfo.version.incremental ?? '未知'),
      Item(title: '支持架构', value: androidDeviceInfo.supportedAbis.toString()),
    ];
  }

  Future<List<Item>> _getPermission() async {
    final List<Item> list = [];
    for (var permission in Permission.values) {
      final PermissionStatus status = await permission.status;
      list.add(Item(title: permission.toString().replaceFirst('Permission.', ''), value: status.value));
    }
    return list;
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(244, 245, 246, 1),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text('基本信息'),
          centerTitle: true,
          leading: const BackButton(
            color: Colors.black,
          ),
        ),
        body: FutureBuilder<bool>(
          future: _controller.future,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: _headers.length,
              itemBuilder: (_, index) {
                return Semantics(
                  /// 将item默认合并的语义拆开，自行组合， 另一种方式见 account_record_list_page.dart
                  explicitChildNodes: true,
                  child: StickyHeader(
                    header: Container(
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      color: Colors.black12,
                      padding: const EdgeInsets.only(left: 16.0),
                      height: 34.0,
                      child: Text(
                        _headers[index],
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                    content: !snapshot.hasData
                        ? Column(
                            children: List.generate(
                                items[index].length,
                                (index) => const Skeleton(
                                      // width: 150,
                                      height: 25,
                                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    )).toList(),
                          )
                        : _buildItem(index),
                  ),
                );
              },
            );
          },
        ));
  }

  Widget _buildItem(int index) {
    final list = List.generate(items[index].length, (i) {
      final Item item = items[index][i];
      return Container(
        width: double.infinity,
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          border: Border(
            bottom: Divider.createBorderSide(context, width: 0.8, color: Colors.white54),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(item.title),
            Flexible(
                child: InkWell(
              child: Text(
                item.value,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.blueGrey),
              ),
              onTap: () async {
                if (item.value.isEmpty) {
                  return;
                }
                await Clipboard.setData(ClipboardData(text: item.value));
                Toast.show('已复制到剪切板!');
              },
            ))
          ],
        ),
      );
    });
    return Column(children: list);
  }
}

class Item {
  final String title;
  final String value;

  Item({required this.title, required this.value});
}

extension ConnectivityResultExtension on ConnectivityResult {
  String get value => ['WIFI', '移动网络', '无网络'][index];
}

extension PermissionStatusExtension on PermissionStatus {
  String get value => ['使用前询问', '允许', '拒绝', '强制拒绝'][index];
}
