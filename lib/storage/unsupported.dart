import 'package:flutter/widgets.dart';

class Storage {
  Future<String> read({@required String key}) async {
    throw UnsupportedError("Platform not supported");
  }

  Future<void> write({@required String key, @required String value}) async {
    throw UnsupportedError("Platform not supported");
  }
}
