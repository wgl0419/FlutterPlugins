import 'dart:convert';

import 'package:example/generated/json_partner/json_partner.dart';
import 'package:example/models/book.dart';
import 'package:example/models/multi_class.dart';
import 'package:example/support_type.dart';

void main() {
  final supportType = SupportType()
    ..boolType = true
    ..intType = 1
    ..doubleType = 3.0
    ..stringType = "string"
    ..listType = [Book()..name = "book"]
    ..mapType = {"a": DataClassA()..propertyA = "propertyA"}
    ..bigIntType = BigInt.two
    ..dateTimeType = DateTime.now()
    ..enumType = EnumType.a;
  final jsonObj = supportType.toJson();
  print(jsonObj);
  print(json.encode(jsonObj));
  final supportType1 = JsonPartner.fromJsonAsT<SupportType>(jsonObj);
  print(supportType1.toJson());
}
