// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// JsonPartner
// **************************************************************************


import 'package:example/models/book.dart';
import 'package:example/models/multi_class.dart';
import 'package:example/models/user/user.dart';
import 'package:example/support_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lib_models_book.g.dart';
part 'lib_models_multi_class.g.dart';
part 'lib_models_user_user.g.dart';
part 'lib_support_type.g.dart';
part 'json_partner.part.dart';

/// JsonPartner
mixin JsonPartner<T> {
  /// toJson
  Map<String, dynamic> toJson() => _getToJson<T>(runtimeType, this);

  /// toJsonByT
  static Map<String, dynamic> toJsonByT<M>(M m) => _getToJson<M>(m.runtimeType, m);

  /// fromJsonAsT
  static M fromJsonAsT<M>(json) => (json is List) ? _getListChildType<M>(json) : _fromJsonSingle<M>(json) as M;
}

bool? _$safelyAsBool(value) => (value is bool) ? value : null;
int? _$safelyAsInt(value) => (value is int) ? value : (value is num) ? value.toInt() : (value is String) ? int.tryParse(value) : int.tryParse(value?.toString() ?? '');
double? _$safelyAsDouble(value) => (value is double) ? value : (value is num) ? value.toDouble() : (value is String) ? double.tryParse(value) : double.tryParse(value?.toString() ?? '');
String? _$safelyAsString(value) => (value is String) ? value : value?.toString();
