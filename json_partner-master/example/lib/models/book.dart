import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Book {
  String? name;
  String? author;
  int? isbn;
  List<String>? keywords;
  Map<String, String>? tags;
}
