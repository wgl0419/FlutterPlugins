import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class DataClassA {
  String? propertyA;
  int? propertyB;

  DataClassA({
    this.propertyA,
    this.propertyB,
  });
}

@JsonSerializable()
class DataClassB {
  String property1;
  int? property2;

  DataClassB({
    required this.property1,
    this.property2,
  });
}
