class TranslatorConfig {
  TranslatorConfig({
    required this.fromPath,
    required this.destPath,
    required this.key,
    required this.baseKey,
    required this.regen,
    required this.langs,
  });
  late final String fromPath;
  late final String destPath;
  late final String key;
  late final String baseKey;
  late final bool regen;
  late final List<String> langs;

  TranslatorConfig.fromJson(Map<String, dynamic> json) {
    fromPath = json['fromPath'];
    destPath = json['destPath'];
    key = json['key'];
    baseKey = json['baseKey'];
    regen = json['regen'];
    langs = List.castFrom<dynamic, String>(json['langs']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['fromPath'] = fromPath;
    _data['destPath'] = destPath;
    _data['key'] = key;
    _data['baseKey'] = baseKey;
    _data['regen'] = regen;
    _data['langs'] = langs;
    return _data;
  }
}
