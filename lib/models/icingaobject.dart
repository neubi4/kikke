import 'package:flutter/material.dart';

abstract class IcingaObject {
  String name;
  Map<String, dynamic> data;

  final String stateField = '';

  final String outputField = '';

  static const state_ok = 0;
  static const state_warning = 1;
  static const state_critical = 2;
  static const state_unknown = 3;

  final borderColors = {
    0: Colors.green[800],
    1: Colors.orange,
    2: Colors.red,
    3: Colors.deepPurple,
  };

  final backgroundColors = {
    0: null,
    1: Colors.orange[50],
    2: Colors.red[50],
    3: Colors.deepPurple[50],
  };

  final icons = {
    0: Icon(Icons.check, color: Colors.green[800]),
    1: Icon(Icons.error, color: Colors.orange),
    2: Icon(Icons.error, color: Colors.red),
    3: Icon(Icons.error, color: Colors.deepPurple),
  };

  String getData(String key) {
    if (this.data.containsKey(key)) {
      return this.data[key];
    }
    return null;
  }

  String getName() {
    return this.getData('object_name');
  }

  Icon getIcon() {
    return this.icons[this.getState()];
  }

  Color getBorderColor() {
    return this.borderColors[this.getState()];
  }

  Color getBackgroundColor() {
    return this.backgroundColors[this.getState()];
  }

  int getState() {
    return int.parse(this.data[this.stateField]);
  }
}
