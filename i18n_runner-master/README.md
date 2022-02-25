# 国际化语言包翻译自动代码生成工具

## 一、安装

在`pubspec.yaml`文件中添加一下依赖

```dart
dev_dependencies:
  ...
  i18n_runner:
    git: git@gitlab.tqxd.com:flutter/plugins/i18n_runner.git
  ...
```
或者
```dart
dev_dependencies:
  ...
  i18n_runner:
    version:  <latest_version>
    hosted:
      name: i18n_runner
      url: https://pub.youzi.dev/api/

  ...
```


## 二、使用

将语言包文件 `i18n.json` 拷贝到 `lib/i18n/` 目录中,然后执行 `flutter pub run i18n_runner` 命令，此工具会根据语言包文件自动生成`lib/i18n/translations/xxx.dart` 语言包代码和 `lib\generated\i18n_keys.dart` 词条资源引用。


```json
// i18n.json文件内容
[
  {
    "id": 200000,
    "key": "home",
    "zhCN": "主页",
    "zhTW": "主頁",
    "en": "homepage",
    "ko": "홈 페이지",
    "ja": "ホームページ",
    "fr": "Page d'accueil",
    "es": "Página principal"
  }
]
```



## 三、高级配置

```yaml
# pubspec.yaml
...
# i18n_runner配置项
i18n_runner:
  files:
    # 国际化Json文件
    json: lib/i18n/i18n.json
    # 国际化Keys文件生成
    i18n_keys: lib/generated/i18n_keys.dart
    # 国际化词条文件包名
    translations: lib/i18n/translations/
  locale:
    # 基准语言，i18n.json里的Key
    benchmark: zhCN
    # 支持的语言，`i18n.json里的Key` => 翻译字典文件和字典Map属性名
    supports:
      zhCN: zh_CN
      zhTW: zh_TW
      en: en_US
      ko: ko
      ja: ja
      fr: fr
      es: es
...

```