// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// JsonPartner
// **************************************************************************

part of 'json_partner.dart';
  
dynamic _getToJson<T>(Type type, data) {
  switch (type) {
    case Book:
      return _$BookToJson(data);
  case DataClassA:
      return _$DataClassAToJson(data);
  case DataClassB:
      return _$DataClassBToJson(data);
  case User:
      return _$UserToJson(data);
  case SupportType:
      return _$SupportTypeToJson(data);

  }
  return data as T;
}

dynamic _fromJsonSingle<M>(json) {
  final type = M.toString();
    if (type == (Book).toString()) {
    return _$BookFromJson(json);
  }
    if (type == (DataClassA).toString()) {
    return _$DataClassAFromJson(json);
  }
    if (type == (DataClassB).toString()) {
    return _$DataClassBFromJson(json);
  }
    if (type == (User).toString()) {
    return _$UserFromJson(json);
  }
    if (type == (SupportType).toString()) {
    return _$SupportTypeFromJson(json);
  }
  
  return null;
}

M _getListChildType<M>(List data) {
    if (<Book>[] is M) {
    return data.map<Book>((e) => _$BookFromJson(e)).toList() as M;
  }
  if (<DataClassA>[] is M) {
    return data.map<DataClassA>((e) => _$DataClassAFromJson(e)).toList() as M;
  }
  if (<DataClassB>[] is M) {
    return data.map<DataClassB>((e) => _$DataClassBFromJson(e)).toList() as M;
  }
  if (<User>[] is M) {
    return data.map<User>((e) => _$UserFromJson(e)).toList() as M;
  }
  if (<SupportType>[] is M) {
    return data.map<SupportType>((e) => _$SupportTypeFromJson(e)).toList() as M;
  }

  throw Exception('not support type');
}

/// BookFactory
extension BookFactory on Book {
  /// fromJson
  static Book fromJson(json) => JsonPartner.fromJsonAsT<Book>(json);
  
  /// toJson
  Map<String, dynamic> toJson() => JsonPartner.toJsonByT(this);
}

/// DataClassAFactory
extension DataClassAFactory on DataClassA {
  /// fromJson
  static DataClassA fromJson(json) => JsonPartner.fromJsonAsT<DataClassA>(json);
  
  /// toJson
  Map<String, dynamic> toJson() => JsonPartner.toJsonByT(this);
}

/// DataClassBFactory
extension DataClassBFactory on DataClassB {
  /// fromJson
  static DataClassB fromJson(json) => JsonPartner.fromJsonAsT<DataClassB>(json);
  
  /// toJson
  Map<String, dynamic> toJson() => JsonPartner.toJsonByT(this);
}

/// UserFactory
extension UserFactory on User {
  /// fromJson
  static User fromJson(json) => JsonPartner.fromJsonAsT<User>(json);
  
  /// toJson
  Map<String, dynamic> toJson() => JsonPartner.toJsonByT(this);
}

/// SupportTypeFactory
extension SupportTypeFactory on SupportType {
  /// fromJson
  static SupportType fromJson(json) => JsonPartner.fromJsonAsT<SupportType>(json);
  
  /// toJson
  Map<String, dynamic> toJson() => JsonPartner.toJsonByT(this);
}
