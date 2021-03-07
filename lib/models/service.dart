import 'package:kikke/models/icingainstance.dart';

import 'host.dart';
import 'icingaobject.dart';

class Service with IcingaObject {
  Host host;
  IcingaInstance instance;

  Map<String, dynamic> data;

  final String fieldPrefix = 'service';

  Service({this.data, this.host, this.instance});

  factory Service.fromJson(Map<String, dynamic> json, Host host, IcingaInstance instance) {
    Service service = Service(
      data: json,
      host: host,
      instance: instance,
    );
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

  String getWebUrl() {
    return "${this.instance.getUrl()}monitoring/service/show?host=${this.host.getName()}&service=${this.getName()}";
  }
}
