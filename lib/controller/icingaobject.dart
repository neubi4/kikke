import 'package:flutter/material.dart';

abstract class IcingaObject {
  String name;
  Map<String, dynamic> data;

  final String stateField = '';

  String getData(String key) {
    if (this.data.containsKey(key)) {
      return this.data[key];
    }
    return null;
  }

  Icon getIcon() {
    return this.getState() ? Icon(Icons.error, color: Colors.red) : Icon(Icons.check, color: Colors.green[800]);
  }

  Color getBackgroundColor() {
    return this.getState() ? Colors.red[200] : null;
  }

  Color getBorderColor() {
    return this.getState() ? Colors.red : Colors.green[800];
  }

  bool getState() {
    print(this.stateField);
    if (this.data[this.stateField] != '0') {
      return true;
    }
    return false;
  }
}
