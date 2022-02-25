// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_partner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataClassA _$DataClassAFromJson(Map<String, dynamic> json) => DataClassA(
      propertyA: _$safelyAsString(json['propertyA']),
      propertyB: _$safelyAsInt(json['propertyB']),
    );

Map<String, dynamic> _$DataClassAToJson(DataClassA instance) =>
    <String, dynamic>{
      'propertyA': instance.propertyA,
      'propertyB': instance.propertyB,
    };

DataClassB _$DataClassBFromJson(Map<String, dynamic> json) => DataClassB(
      property1: _$safelyAsString(json['property1'])!,
      property2: _$safelyAsInt(json['property2']),
    );

Map<String, dynamic> _$DataClassBToJson(DataClassB instance) =>
    <String, dynamic>{
      'property1': instance.property1,
      'property2': instance.property2,
    };
