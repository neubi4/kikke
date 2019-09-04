import 'package:mobilemon/controller/hostcontroller.dart';
import 'package:mobilemon/models/icingaobject.dart';
import 'package:mobilemon/controller/servicecontroller.dart';
import 'package:mobilemon/models/host.dart';

class Service with IcingaObject {
  Host host;
  HostController hostController;
  ServiceController serviceController;

  Map<String, dynamic> data;

  final String fieldPrefix = 'service';

  Service({this.data, this.host, this.serviceController});

  factory Service.fromJson(Map<String, dynamic> json, Host host, ServiceController serviceController) {
    Service service = Service(
      data: json,
      host: host,
      serviceController: serviceController,
    );
    service.hostController = host.controller;
    return service;
  }

  void update(Map<String, dynamic> json) {
    this.data.addAll(json);
  }

  String getName() {
    return this.getData('description');
  }

  String getDisplayName() {
    if (this.getData('display_name') != null) {
      return this.getData('display_name');
    }
    return this.getData('description');
  }
}
