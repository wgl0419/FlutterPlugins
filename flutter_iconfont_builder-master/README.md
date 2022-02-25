# Flutter IconFont Builder

IconFont Builder

## 使用

🔩 安装

在 `pubspec.yaml` 添加依赖

```
flutter_iconfont_builder:
    hosted:
      name: flutter_iconfont_builder
      url: https://pub.youzi.dev
    version: <last_version>
```

⚙️ 配置

```
flutter_iconfont_builder:
  dart-file-path: lib/generated  # 默认
  html-file-path: lib/generated  # 默认
  ttf-file-path: assets/fonts    # 默认
  fonts:
    - font-family: "iconfont"
      css: "https://at.alicdn.com/t/font_834326_mygezrh3a4.css"
```

🔨 使用

```dart
import 'package:yourpackage/generated/IconFont.g.dart';
Icon(IconFont.xxxxx);
```

## Changelog

Refer to the [Changelog](CHANGELOG.md) to get all release notes.