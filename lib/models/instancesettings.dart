class InstanceSetting {
  String name;
  String url;
  String username;
  String password;

  InstanceSetting(
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
        'name': instance.name,
        'url': instance.url,
        'username': instance.username,
        'password': instance.password,
      });
    });
    return l;
  }
}
