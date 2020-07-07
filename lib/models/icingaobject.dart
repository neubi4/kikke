import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'icingainstance.dart';


abstract class IcingaObject {
  String name;
  Map<String, dynamic> data;

  IcingaInstance instance;

  final String fieldPrefix = '';
  final String stateField = 'state';
  final String outputField = 'output';
  final String lastStateChangeField = 'last_state_change';
  final String checkCommandField = 'check_command';

  static const state_ok = 0;
  static const state_warning = 1;
  static const state_critical = 2;
  static const state_unknown = 3;

  final stateToText = {
    0: "Ok",
    1: "Warning",
    2: "Critical",
    3: "Unkown",
  };

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

  final backgroundColorsDark = {
    0: null,
    1: Color(0xFF2B1B00),
    2: Color(0xFF2B0000),
    3: Color(0xFF12002E),
  };

  final icons = {
    0: Icon(Icons.check, color: Colors.green[800]),
    1: Icon(Icons.error, color: Colors.orange),
    2: Icon(Icons.error, color: Colors.red),
    3: Icon(Icons.error, color: Colors.deepPurple),
  };

  final iconColors = {
    'acknowledged': Colors.green,
    'in_downtime': Colors.black45,
  };

  final iconColorsDark = {
    'acknowledged': Colors.green[900],
    'in_downtime': Colors.white54,
  };

  String getRawData(String key) {
    if (this.data.containsKey(key)) {
      return this.data[key];
    }
    return "";
  }

  String getData(String key) {
    return this.getRawData("${this.fieldPrefix}_$key");
  }

  String getName() {
    return this.getRawData('object_name');
  }

  String getDisplayName() {
    return this.getRawData('object_name');
  }

  String getAllNames() {
    return "${this.getData('display_name')} ${this.getData('description')} ${this.getData('display_name')} ${this.getData('object_name')} ";
  }

  Icon getIcon() {
    return this.icons[this.getState()];
  }

  Color getBorderColor() {
    return this.borderColors[this.getState()];
  }

  Color getBackgroundColor(BuildContext context) {
    var colors = this.backgroundColors;
    if (Theme.of(context).brightness == Brightness.dark) {
      colors = this.backgroundColorsDark;
    }

    return colors[this.getState()];
  }

  Color getIconColor(BuildContext context, String type) {
    var colors = this.iconColors;
    if(Theme.of(context).brightness == Brightness.dark) {
      colors = this.iconColorsDark;
    }

    return colors[type];
  }

  String getStateText() {
    return this.stateToText[this.getState()];
  }

  int getState() {
    return int.parse(this.getData(this.stateField));
  }

  int getWeight() {
    int weight = 0;

    switch (this.getState()) {
      case 1:
        weight = 40;
        break;
      case 2:
        weight = 50;
        break;
      case 3:
        weight = 30;
        break;
    }

    return weight;
  }

  String getDateFieldSince(String field) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(double.parse(this.getData(field)).toInt() * 1000);

    return timeago.format(date, allowFromNow: true);
  }

  String getStateSince() {
    return this.getDateFieldSince(this.lastStateChangeField);
  }

  String getStateSinceDate() {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(this.getData(this.lastStateChangeField)) * 1000);

    return "${DateFormat.yMMMd().format(date)} ${DateFormat.Hms().format(date)}";
  }

  String getInstanceName() {
    return this.instance.name;
  }
}
