import 'package:mobilemon/controller/hostcontroller.dart';
import 'package:mobilemon/controller/icingaobject.dart';
import 'package:mobilemon/controller/servicecontroller.dart';
import 'package:mobilemon/models/host.dart';

class Service with IcingaObject {
  Host host;
  HostController hostController;
  ServiceController serviceController;

  Map<String, dynamic> data;

  final String stateField = 'service_state';

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
    if (this.getData('service_display_name') != null) {
      return "${this.host.getName()}: ${this.getData('service_display_name')} (${this.getData('service_description')})";
    }
    return "${this.host.getName()}:${this.getData('service_description')}";
  }
}
