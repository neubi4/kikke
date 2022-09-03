import 'package:kikke/models/icingainstance.dart';

import 'host.dart';
import 'icingaobject.dart';

class Service with IcingaObject implements Comparable {
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

  @override
  int compareTo(other) {
    List<int> compares = [
      (this.getDataAsInt('severity') * -1).compareTo(other.getDataAsInt('severity') * -1),
      (int.parse(this.getData('acknowledged'))).compareTo(int.parse(other.getData('acknowledged'))),
      this.getName().toLowerCase().compareTo(other.getName().toLowerCase()),
      (this.getDataAsInt('last_state_change') * -1).compareTo((other.getDataAsInt('last_state_change') * -1)),
    ];

    return this.compare(compares);
  }
}
