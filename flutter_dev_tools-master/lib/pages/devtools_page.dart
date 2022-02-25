import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_base_kit/flutter_base_kit.dart';
import 'package:flutter_dev_tools/controlles/devtools_controller.dart';
import 'package:flutter_dev_tools/routes/dev_tools_route.dart';

class DevToolsPage extends GetView<DevToolsController> {
  const DevToolsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(244, 245, 246, 1),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text('Flutter 调试工具'),
          centerTitle: true,
          leading: const BackButton(
            color: Colors.black,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Section(
                title: '常用工具',
                items: [
                  Item(
                      iconImage: Icons.info,
                      title: '基本信息',
                      onPress: () {
                        Get.toNamed(Routes.infoPage);
                      }),
                  Item(
                      iconImage: Icons.inbox,
                      title: '沙盒浏览器',
                      onPress: () {
                        Get.toNamed(Routes.sandboxPage);
                      }),
                  Item(iconImage: Icons.location_on_outlined, title: '位置模拟', onPress: () async {}),
                  Item(iconImage: Icons.web, title: 'H5-SDK', onPress: () {}),
                  Item(
                      iconImage: Icons.settings_backup_restore,
                      title: '一键还原',
                      onPress: () async {
                        final Directory tempDir = await getTemporaryDirectory();
                        final Directory imgTempDir = Directory('${tempDir.path}/IMG_TEMP');
                        if (!imgTempDir.existsSync()) {
                          await imgTempDir.create();
                        }
                      }),
                  Item(
                      iconImage: Icons.note,
                      title: '日志管理',
                      onPress: () async {
                        Get.toNamed(Routes.loggyStreamPage);
                      }),
                  Item(
                      iconImage: Icons.storage,
                      title: 'SP管理',
                      onPress: () {
                        Get.toNamed(Routes.sharedPreferencesPage);
                      }),
                  Item(
                      iconImage: Icons.network_check_rounded,
                      title: '网络工具',
                      onPress: () {
                        Get.toNamed(Routes.networkPage);
                      }),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Section(
                title: 'CI/CD',
                items: [
                  Item(
                      iconImage: Icons.apps,
                      title: '应用列表',
                      onPress: () {
                        Get.toNamed(Routes.appListPage);
                      }),
                  Item(iconImage: Icons.auto_awesome_motion, title: 'CI/CD', onPress: () {}),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Section(
                title: '业务工具',
                items: [
                  Item(
                      iconImage: Icons.account_box_outlined,
                      title: '账号管理',
                      onPress: () {
                        Toast.show('app信息');
                      }),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Section(
                title: '平台工具',
                items: [
                  Item(
                      iconImage: Icons.data_usage_rounded,
                      title: 'Mock数据',
                      onPress: () {
                        Toast.show('app信息');
                      }),
                  Item(iconImage: Icons.sync, title: '文件同步', onPress: () {}),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Section(
                title: '视觉工具',
                items: [
                  Item(
                      iconImage: Icons.colorize,
                      title: '取色',
                      onPress: () {
                        Toast.show('app信息');
                      }),
                  Item(iconImage: Icons.zoom_in, title: '标尺', onPress: () {}),
                  Item(iconImage: Icons.stream, title: '布局', onPress: () {}),
                  Item(iconImage: Icons.account_tree_outlined, title: '结构', onPress: () {}),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Section(
                title: '性能检测',
                items: [
                  Item(
                      iconImage: Icons.speed,
                      title: '帧率',
                      onPress: () {
                        Toast.show('app信息');
                      }),
                  Item(iconImage: Icons.casino_outlined, title: 'CPU', onPress: () {}),
                  Item(iconImage: Icons.memory, title: '内存', onPress: () {}),
                  Item(iconImage: Icons.child_care_sharp, title: 'Crash', onPress: () {}),
                  Item(iconImage: Icons.av_timer, title: '启动耗时', onPress: () {}),
                ],
              ),
            ],
          ),
        ));
  }
}

class Section extends StatelessWidget {
  final String title;
  final List<Item> items;

  const Section({Key? key, required this.title, required this.items}) : super(key: key);

  Color get randomColor {
    return Color.fromARGB(255, Random().nextInt(256) + 0, Random().nextInt(256) + 0, Random().nextInt(256) + 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(
                height: 12,
              ),
              GridView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                physics: const NeverScrollableScrollPhysics(),
                // padding: EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  // childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final Item item = items[index];
                  return InkWell(
                    onTap: item.onPress,
                    child: Column(
                      children: [
                        Icon(
                          item.iconImage,
                          size: 32,
                          color: randomColor,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(item.title)
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ));
  }
}

class Item {
  final IconData iconImage;
  final String title;
  final VoidCallback onPress;

  const Item({required this.iconImage, required this.title, required this.onPress});
}
