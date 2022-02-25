// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_partner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportType _$SupportTypeFromJson(Map<String, dynamic> json) => SupportType()
  ..boolType = _$safelyAsBool(json['boolType'])
  ..intType = _$safelyAsInt(json['intType'])
  ..doubleType = (json['doubleType'] as num?)?.toDouble()
  ..stringType = _$safelyAsString(json['stringType'])
  ..listType = (json['listType'] as List<dynamic>?)
      ?.map((e) => _$BookFromJson(e as Map<String, dynamic>))
      .toList()
  ..mapType = (json['mapType'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, _$DataClassAFromJson(e as Map<String, dynamic>)),
  )
  ..bigIntType = json['bigIntType'] == null
      ? null
      : BigInt.parse(_$safelyAsString(json['bigIntType'])!)
  ..dateTimeType = json['dateTimeType'] == null
      ? null
      : DateTime.parse(_$safelyAsString(json['dateTimeType'])!)
  ..enumType = $enumDecodeNullable(_$EnumTypeEnumMap, json['enumType']);

Map<String, dynamic> _$SupportTypeToJson(SupportType instance) =>
    <String, dynamic>{
      'boolType': instance.boolType,
      'intType': instance.intType,
      'doubleType': instance.doubleType,
      'stringType': instance.stringType,
      'listType': $toJsonListBook(instance.listType),
      'mapType': $toJsonMapStringDataClassA(instance.mapType),
      'bigIntType': instance.bigIntType?.toString(),
      'dateTimeType': instance.dateTimeType?.toIso8601String(),
      'enumType': _$EnumTypeEnumMap[instance.enumType],
    };

const _$EnumTypeEnumMap = {
  EnumType.a: 'a',
  EnumType.b: 'b',
};
