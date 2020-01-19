import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kikke/models/service.dart';

import 'host.dart';

class IcingaInstance {
  String name;
  String url;
  String username;
  String password;

  Map<String, Service> services = new Map();
  Map<String, Host> hosts = new Map();

  bool fetchedAllServices = false;
  bool fetchedAllHosts = false;
  DateTime lastUpdateServices = new DateTime(1970);
  DateTime lastUpdateHosts = new DateTime(1970);

  IcingaInstance(this.name, this.url, this.username, this.password);

  String getAuthData() {
    return base64Encode(utf8.encode("${this.username}:${this.password}"));
  }

  String getUrl() {
    String url = Uri.parse(this.url).toString();
    if (!url.endsWith('/')) {
      url += '/';
    }

    return url;
  }

  Future checkData() async {
    final headers = Map<String, String>();
    final auth = base64Encode(utf8.encode("${this.username}:${this.password}"));
    String icingaUrl = Uri.parse(this.url).toString();
    if (!icingaUrl.endsWith('/')) {
      icingaUrl += '/';
    }

    headers['Authorization'] = "Basic $auth";
    headers['Accept'] = "application/json";

    final response = await http.get('${icingaUrl}monitoring/list/hosts?limit=1&format=json', headers: headers);
    if (response.statusCode == 401) {
      throw Exception('Status Code 401 Unauthorized!');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to load, ${response.statusCode} ${response.request.method} ${response.request.url}');
    }
  }

  Map<String, String> getDefaultHeaders() {
    final headers = Map<String, String>();
    final auth = this.getAuthData();
    headers['Authorization'] = "Basic $auth";
    headers['Accept'] = "application/json";

    return headers;
  }

  Future fetchServices() async {
    this.lastUpdateServices = DateTime.now();
    final headers = this.getDefaultHeaders();

    print("${this.name} fetching services");

    String icingaUrl = this.getUrl();

    final response = await http.get('${icingaUrl}monitoring/list/services?format=json&limit=10000', headers: headers);
    if (response.statusCode == 200) {
      var jsonData = (json.decode(response.body) as List);

      for (var i = 0; i < jsonData.length; i++) {
        await this.parseServiceRow(jsonData[i]);
      }

      this.fetchedAllServices = true;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load services, ${response.request.method} ${response.request.url} ${response.statusCode} ${response.body}');
    }
  }

  Future parseServiceRow(Map<String, dynamic> item) async {
    if (this.services.containsKey(item['host_name'] + item['service_description'])) {
      this.services[item['host_name'] + item['service_description']].update(item);
    } else {
      Host host = await this.getHost(item['host_name']);
      this.services[item['host_name'] + item['service_description']] = Service.fromJson(item, host, this);
    }
  }

  Future fetchHosts() async {
    this.lastUpdateHosts = DateTime.now();

    final headers = this.getDefaultHeaders();

    print("${this.name} fetching hosts");

    String icingaUrl = this.getUrl();

    final response = await http.get('${icingaUrl}monitoring/list/hosts?limit=10000&format=json', headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      jsonData.forEach((item) {
        if (this.hosts.containsKey(item['host_name'])) {
          this.hosts[item['host_name']].update(item);
        } else {
          this.hosts[item['host_name']] = Host.fromJson(item, this);
        }

        this.fetchedAllHosts = true;
      });
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load host, ${response.request.method} ${response.request.url} ${response.statusCode} ${response.body}');
    }
  }

  Future<Host> getHost(String hostName) async {
    await this.checkUpdateHosts();

    if (this.hosts.containsKey(hostName)) {
      return this.hosts[hostName];
    }
    return null;
  }

  Future<void> checkUpdateHosts() async {
    Duration diff = DateTime.now().difference(this.lastUpdateHosts);
    if (!this.fetchedAllHosts | (diff.inSeconds > 60)) {
      await this.fetchHosts();
    }
  }

  Future<void> checkUpdateServices() async {
    Duration diff = DateTime.now().difference(this.lastUpdateServices);
    if (!this.fetchedAllServices | (diff.inSeconds > 60)) {
      await this.fetchServices();
    }
  }
}
