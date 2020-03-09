import 'package:uuid/uuid.dart';

class InstanceSetting {
  String id;
  String name;
  String url;
  String username;
  String password;

  InstanceSetting(
    this.id,
    this.name,
    this.url,
    this.username,
    this.password,
  );
}

class InstanceSettings {
  List<InstanceSetting> instances = [];

  InstanceSettings.fromJson(List<dynamic> json) {
    json.forEach((data) {
      InstanceSetting i = InstanceSetting(
        data.containsKey('id') ? data['id'] : Uuid().v4(),
        data['name'],
        data['url'],
        data['username'],
        data['password'],
      );
      this.instances.add(i);
    });
  }

  List<dynamic> toJson() {
    List l = [];
    this.instances.forEach((instance) {
      l.add({
        'id': instance.id,
        'name': instance.name,
        'url': instance.url,
        'username': instance.username,
        'password': instance.password,
      });
    });
    return l;
  }
}
