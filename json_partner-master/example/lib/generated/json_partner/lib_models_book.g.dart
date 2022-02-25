// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_partner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book()
  ..name = _$safelyAsString(json['name'])
  ..author = _$safelyAsString(json['author'])
  ..isbn = _$safelyAsInt(json['isbn'])
  ..keywords =
      (json['keywords'] as List<dynamic>?)?.map((e) => _$safelyAsString(e)!).toList()
  ..tags = (json['tags'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, _$safelyAsString(e)!),
  );

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'name': instance.name,
      'author': instance.author,
      'isbn': instance.isbn,
      'keywords': instance.keywords,
      'tags': instance.tags,
    };
