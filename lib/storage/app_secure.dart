import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage_interface.dart';

class Storage implements StorageInterface {
  final storage = new FlutterSecureStorage();

  Future<String> read({@required String key}) async {
    return storage.read(key: key);
  }

  Future<void> write({@required String key, @required String value}) async {
    return storage.write(key: key, value: value);
  }
}
