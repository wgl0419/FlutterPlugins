import 'package:flutter_base_kit/utils/storage_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('test simple storage', () {
    SimpleStorage storage = SimpleStorage();
    test('test int, string, bool', () async {
      // await storage.write('test_key', 123456);
      // expect(123456, storage.read<Map>('test_key'));
      storage.read<List<String>>('test_key1');
      storage.read<List<int>>('test_key2');
      storage.read<Map>('test_key3');
      storage.read<Map<String, dynamic>>('test_key4');
    });
  });
}

class City {
  String name;

  City({required this.name});

  /// must.
  City.fromJson(Map<String, dynamic> json) : name = json['name'];

  /// must.
  Map<String, dynamic> toJson() => {
        'name': name,
      };

  @override
  String toString() {
    StringBuffer sb = StringBuffer('{');
    sb.write("\"name\":\"$name\"");
    sb.write('}');
    return sb.toString();
  }
}
