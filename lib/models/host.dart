import 'package:kikke/models/icingainstance.dart';
import 'package:kikke/models/icingaobject.dart';

class Host with IcingaObject implements Comparable {
  String name;
  String address;
  Map<String, dynamic> data;

  IcingaInstance instance;

  final stateToText = {
    0: "Up",
    1: "Down",
    2: "Down",
    3: "Down",
  };

  final String fieldPrefix = 'host';

  Host({this.name, this.data, this.instance});

  factory Host.fromJson(Map<String, dynamic> json, IcingaInstance instance) {
    return Host(
      name: json['host_name'],
      data: json,
      instance: instance,
    );
  }

  void update(Map<String, dynamic> json) {
    this.name = json['host_name'];
    this.data.addAll(json);
  }

  String getName() {
    return "${this.name}";
  }

  String getDisplayName() {
    if (this.getData('display_name') != null) {
      return "${this.getData('display_name')}";
    }
    return "${this.name}";
  }

  String getWebUrl() {
    return "${this.instance.getUrl()}monitoring/host/show?host=${this.getName()}";
  }

  @override
  int compareTo(other) {
    List<int> compares = [
      (this.getDataAsInt('state') * -1).compareTo((other.getDataAsInt('state') * -1)),
      this.getName().toLowerCase().compareTo(other.getName().toLowerCase()),
      (this.getDataAsInt('last_state_change') * -1).compareTo((other.getDataAsInt('last_state_change') * -1))
    ];

    return this.compare(compares);
  }
}
