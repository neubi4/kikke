import 'package:flutter/material.dart';
import 'package:mobilemon/controller/hostcontroller.dart';
import 'package:mobilemon/models/icingaobject.dart';

class Host with IcingaObject {
  String name;
  String address;
  Map<String, dynamic> data;

  HostController controller;

  final String stateField = 'host_state';

  final String outputField = 'host_output';

  Host({this.name, this.data, this.controller});

  factory Host.fromJson(Map<String, dynamic> json, HostController controller) {
    return Host(
      name: json['host_name'],
      data: json,
      controller: controller,
    );
  }

  void update(Map<String, dynamic> json) {
    this.name = json['host_name'];
    this.data.addAll(json);
  }

  String getName() {
    if (this.getData('host_display_name') != null) {
      return "${this.getData('host_display_name')} (${this.name})";
    }
    return "${this.name}";
  }
}
