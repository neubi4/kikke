import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  SharedPreferences prefs;

  Future<String> read({@required String key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> write({@required String key, @required String value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
}
