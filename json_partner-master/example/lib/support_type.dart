import 'package:example/generated/json_partner/json_partner.dart';
import 'package:example/models/book.dart';
import 'package:example/models/multi_class.dart';
import 'package:json_annotation/json_annotation.dart';

enum EnumType { a, b }

@JsonSerializable()
class SupportType {
  bool? boolType;
  int? intType;
  double? doubleType;
  String? stringType;
  @JsonKey(toJson: $toJsonListBook)
  List<Book>? listType;
  @JsonKey(toJson: $toJsonMapStringDataClassA)
  Map<String, DataClassA>? mapType;
  BigInt? bigIntType;
  DateTime? dateTimeType;
  EnumType? enumType;
}

List<dynamic>? $toJsonListBook(List<Book>? source) {
  return source?.map((e) => e.toJson()).toList();
}

Map<String, dynamic>? $toJsonMapStringDataClassA(
    Map<String, DataClassA>? source) {
  return source?.map((key, value) => MapEntry(key, value.toJson()));
}
