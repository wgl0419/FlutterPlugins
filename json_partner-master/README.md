# [json_serializable] JSON代码生成器辅助工具

## 一、安装

在`pubspec.yaml`文件中添加一下依赖

```dart
dependencies:
  json_annotation: ^4.3.0

dev_dependencies:
  build_runner: ^2.1.2
  json_serializable: ^6.0.1
  json_partner:
    git: git@gitlab.tqxd.com:flutter/plugins/json_partner.git
```

或者

```dart
dependencies:
  json_annotation: ^4.3.0

dev_dependencies:
  build_runner: ^2.1.4
  json_serializable: ^6.0.1
  json_partner:
    version:  <latest_version>
    hosted:
      name: json_partner
      url: https://pub.youzi.dev/api/
```


## 二、使用

> 此工具依赖于google的`json_serializable`插件，所以项目中也应该引入`json_serializable`

进入项目根目录 *（即`lib`文件夹所在目录）* 执行`flutter pub run json_partner`命令，此工具会自动在`lib/generated/json_partner`目录下生成序列化数据类需要用的`toJson`和`fromJsonAsT`方法。


## 三、数据模块类示例

```dart
/// file: lib/models/book.dart

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Book {
  String? username;
  int? age;
  List<String>? keyword;
  Map<String, String>? tags;
}

```

