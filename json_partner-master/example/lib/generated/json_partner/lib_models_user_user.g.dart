// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_partner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User()
  ..username = _$safelyAsString(json['username'])
  ..age = _$safelyAsInt(json['age']);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'username': instance.username,
      'age': instance.age,
    };
