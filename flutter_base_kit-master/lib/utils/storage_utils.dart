import 'dart:convert';

import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_base_kit/flutter_base_kit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageUtils {
  StorageUtils._();

  static late StorageInterface _sp;

  static StorageInterface get sp => _sp;

  static late SecureStorage _ss;

  static SecureStorage get ss => _ss;

  static Future<bool> init() async {
    /// 初始化简单存储
    _sp = SimpleStorage();
    await _sp.init();

    /// 初始化加密存储
    _ss = SecureStorage();
    await _ss.init();

    return true;
  }
}

class SimpleStorage implements StorageInterface {
  @override
  Future<bool>? clearAll() {
    return SpUtil.clear();
  }

  @override
  Future<bool>? delete(String key) {
    return SpUtil.remove(key);
  }

  @override
  Future<bool> init([String? storageName]) async {
    await SpUtil.getInstance();
    return SpUtil.isInitialized();
  }

  @override
  Set<String>? keys() {
    return SpUtil.getKeys();
  }

  @override
  T? read<T>(String key, [T? defaultValue]) {
    switch (T) {
      case bool:
        {
          return SpUtil.getBool(key, defValue: defaultValue as bool?) as T?;
        }
      case String:
        return SpUtil.getString(key, defValue: defaultValue as String?) as T?;
      case int:
        return SpUtil.getInt(key, defValue: defaultValue as int?) as T?;
      case double:
        return SpUtil.getDouble(key, defValue: defaultValue as double?) as T?;
      case List:
        return SpUtil.getObjectList(key) as T?;
      case Map:
        return SpUtil.getObject(key) as T?;
    }
    if (T.toString().contains('List<String>')) {
      return SpUtil.getStringList(key, defValue: defaultValue as List<String>?) as T?;
    } else if (T.toString().startsWith('List<')) {
      return SpUtil.getObjectList(key) as T?;
    } else if (T.toString().startsWith('Map<')) {
      return SpUtil.getObject(key) as T?;
    }
    throw UnsupportedError('not supported type.');
  }

  @override
  Future<bool> write(String key, dynamic value) {
    final _default = Future.value(false);
    if (value is bool) {
      return SpUtil.putBool(key, value) ?? _default;
    } else if (value is String) {
      return SpUtil.putString(key, value) ?? _default;
    } else if (value is int) {
      return SpUtil.putInt(key, value) ?? _default;
    } else if (value is double) {
      return SpUtil.putDouble(key, value) ?? _default;
    } else if (value is Object) {
      if (value is List) {
        if (value is List<String>) {
          return SpUtil.putStringList(key, value) ?? _default;
        }
        return SpUtil.putObjectList(key, value as List<Object>) ?? _default;
      }
      return SpUtil.putObject(key, value) ?? _default;
    } else {
      throw UnsupportedError('not supported type.');
    }
  }
}

class SecureStorage implements StorageInterface {
  late Box _box;

  @override
  Future<bool>? clearAll() async {
    await _box.clear();
    return true;
  }

  @override
  Future<bool>? delete(String key) async {
    await _box.delete(key);
    return true;
  }

  @override
  Future<bool> init([String? storageName]) async {
    await Hive.initFlutter();
    if (!kIsWeb) {
      const FlutterSecureStorage secureStorage = FlutterSecureStorage();
      var containsEncryptionKey = await secureStorage.containsKey(key: 'key');
      if (!containsEncryptionKey) {
        var key = Hive.generateSecureKey();
        await secureStorage.write(key: Constant.secureStorageKey, value: base64UrlEncode(key));
      }

      var key = await secureStorage.read(key: Constant.secureStorageKey);
      var encryptionKey = base64Url.decode(key!);
      _box = await Hive.openBox('application', encryptionCipher: HiveAesCipher(encryptionKey));
    } else {
      _box = await Hive.openBox('application');
    }

    return true;
  }

  @override
  Set<String>? keys() {
    return _box.keys.toSet() as Set<String>;
  }

  @override
  T? read<T>(String key, [T? defaultValue]) {
    return _box.get(key, defaultValue: defaultValue) as T;
  }

  @override
  Future<bool> write(String key, value) async {
    await _box.put(key, value);
    return true;
  }
}

abstract class StorageInterface {
  Future<bool> init([String? storageName]);

  /// 写入
  Future<bool> write(String key, dynamic value);

  /// 读取
  T? read<T>(String key, [T? defaultValue]);

  /// 获取所有Key
  Set<String>? keys();

  /// 删除Key
  Future<bool>? delete(String key);

  /// 清空所有Key
  Future<bool>? clearAll();
}
