part of http;

abstract class ResponseTransformer {
  // Future<ResponseModel<T>> _onTransform<T>(Object? data) async {
  //   final dataType = data.runtimeType.toString();
  //
  //   /// 如果data为null, 并且不为json, 则自行组装数据.
  //   if (data == null || !dataType.contains('Map<')) {
  //     return ResponseModel.init(200, 'ok', data: data as T);
  //   }
  //   final json = data as Map<String, dynamic>;
  //   final code = getCode(json);
  //   final msg = getMessage(json);
  //   final obj = _convertData(getData(json));
  //   return ResponseModel.init(code, msg, data: obj as T);
  // }

  /// onTransform
  Future<ResponseModel<T>> onTransform<T>(Object? data);

  // /// 数据类型转换
  // Future<T?>? convertData<T>(Object? data);

  // /// 由接入方自行实现转模型操作
  // T? convertObj<T>(Map<String, dynamic>? data);
}

// abstract class ResponseTransformer implements ResponseTransformerInterface {
//   /// 数据类型转换
//   @override
//   Future<T?>? convertData<T>(Object? data) async {
//     final String tType = T.toString();
//     if (data == null || tType == 'null' || tType == 'void') {
//       return null;
//     } else if (tType == 'dynamic') {
//       return Future.value(data as T);
//     } else if (T is String) {
//       return Future.value(data.toString() as T);
//     } else if (T is bool) {
//       final bool ok = data.toString().toLowerCase() == 'true';
//       return Future.value(ok as T);
//     } else if (tType.contains('Map<') || tType.contains('List<')) {
//       if (data.runtimeType.toString().contains('Map<') || tType.contains('List<')) {
//         return Future.value(data as T);
//       }
//       final json = await JsonTransformer.decode(data.toString());
//       return Future.value(json as T);
//     } else {
//       return convertObj(data as Map<String, dynamic>);
//     }
//   }
// }
