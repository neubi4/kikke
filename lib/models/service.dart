import 'package:mobilemon/models/host.dart';

class Service {
  Host host;

  Map<String, dynamic> data;

  Service({this.data, this.host});

  factory Service.fromJson(Map<String, dynamic> json, Host host) {
    return Service(
      data: json,
      host: host,
    );
  }

  void update(Map<String, dynamic> json) {
    this.data.addAll(json);
  }
}
