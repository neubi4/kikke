import 'package:mobilemon/models/icingainstance.dart';
import 'package:mobilemon/models/icingaobject.dart';

class Host with IcingaObject {
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
}
