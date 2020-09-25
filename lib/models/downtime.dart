import 'package:flutter/material.dart';
import 'package:kikke/models/icingaobject.dart';

import 'icingainstance.dart';

class Downtime with IcingaObject {
  String name;
  String address;
  Map<String, dynamic> data;

  IcingaInstance instance;

  Downtime({this.name, this.data, this.instance});

  factory Downtime.fromJson(Map<String, dynamic> json, IcingaInstance instance) {
    return Downtime(
      name: json['name'],
      data: json,
      instance: instance,
    );
  }

  void update(Map<String, dynamic> json) {
    this.name = json['name'];
    this.data.addAll(json);
  }

  String getName() {
    return this.getRawData('name');
  }

  String getDisplayName() {
    return this.getRawData('name');
  }

  String getAllNames() {
    return "${this.getData('name')}";
  }

  Icon getIcon() {
    return Icon(Icons.access_time);
  }

  int getState() {
    return 0;
  }
}
