import 'package:flutter/widgets.dart';

abstract class StorageInterface {
  Future<String> read({@required String key}) async {
    return "";
  }

  Future<void> write({@required String key, @required String value}) async {}
}
