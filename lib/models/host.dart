import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Host implements Comparable<Host> {
  String name;
  String address;
  Map<String, dynamic> data;

  Host({this.name, this.data});

  factory Host.fromJson(Map<String, dynamic> json) {
    return Host(
      name: json['host_name'],
      data: json,
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

  String getData(String key) {
    if (this.data.containsKey(key)) {
      return this.data[key];
    }
    return null;
  }

  Icon getIcon() {
    return this.getState() ? Icon(Icons.error, color: Colors.white,) : Icon(Icons.check, color: Colors.green[800]);
  }

  Color getBackgroundColor() {
    return this.getState() ? Colors.deepOrangeAccent[400] : null;
  }

  bool getState() {
    if (this.data['host_state'] == '1') {
      return true;
    }
    return false;
  }

  int compareTo(Host b) {
    if (this.getData('host_state') == "1" && b.getData('host_state') == "1") {
      return 0;
    } else if (this.getData('host_state') == "1" && b.getData('host_state') == "0") {
      return 1;
    } else {
      return -1;
    }
  }
}
