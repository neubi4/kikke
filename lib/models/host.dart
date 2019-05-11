import 'package:mobilemon/controller/hostcontroller.dart';
import 'package:mobilemon/models/icingaobject.dart';

class Host with IcingaObject {
  String name;
  String address;
  Map<String, dynamic> data;

  HostController controller;

  final String fieldPrefix = 'host';

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
    if (this.getData('display_name') != null) {
      return "${this.getData('display_name')}";
    }
    return "${this.name}";
  }
}
