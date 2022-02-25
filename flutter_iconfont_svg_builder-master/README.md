# Flutter IconFont Svg Builder

IconFont Svg Builder

## 使用

🔩 安装

在 `pubspec.yaml` 添加依赖

```
flutter_iconfont_svg_builder:
    hosted:
      name: flutter_iconfont_svg_builder
      url: https://pub.youzi.dev
    version: <last_version>
```

⚙️ 配置

```
flutter_iconfont_svg_builder:
  fonts:
    -
      class-name: IconFont
      dart-file-dir:
      svg-symbol: 
        - https://at.alicdn.com/t/font_2900776_ykp3dhmbyrr.js?spm=a313x.7781069.1998910419.73&file=font_2900776_ykp3dhmbyrr.js
        - https://lf1-cdn-tos.bytegoofy.com/obj/iconpark/svg_4211_4.eacc32d3d7223561827b5aefd9996bcc.js
    -
      class-name: IconPark
      dart-file-dir:
      svg-symbol: https://lf1-cdn-tos.bytegoofy.com/obj/iconpark/svg_4211_4.eacc32d3d7223561827b5aefd9996bcc.js
```

🔨 使用

```dart
import 'package:yourpackage/generated/icon_font.g.dart';
IconFont(IconFont.iconAZiyuan6)
```

## Changelog

Refer to the [Changelog](CHANGELOG.md) to get all release notes.
