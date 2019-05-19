import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobilemon/controller/appsettings.dart';
import 'package:mobilemon/controller/icingacontroller.dart';
import 'package:mobilemon/controller/servicecontroller.dart';

import 'package:mobilemon/models/host.dart';
import 'package:queries/collections.dart';

class HostController implements IcingaObjectController {
  Map<String, Host> hosts = new Map();
  bool fetchedAllHosts = false;
  DateTime lastUpdate = new DateTime(1970);

  AppSettings appSettings;
  ServiceController serviceController;

  HostController({this.appSettings, this.serviceController});

  void reset() {
    this.lastUpdate = DateTime(1970);
    this.fetchedAllHosts = false;
    this.hosts.clear();
  }

  Future fetch() async {
    this.lastUpdate = DateTime.now();

    final headers = Map<String, String>();
    final auth = await this.appSettings.getAuthData();
    headers['Authorization'] = "Basic $auth";
    headers['Accept'] = "application/json";

    print("fetching hosts");

    String icingaUrl = await this.appSettings.getIcingaUrl();

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
  
  Future fetchHost(Host host) async {
    final headers = Map<String, String>();
    final auth = await this.appSettings.getAuthData();
    headers['Authorization'] = "Basic $auth";
    headers['Accept'] = "application/json";

    print("fetching host ${host.getData('name')}");

    String icingaUrl = await this.appSettings.getIcingaUrl();

    final response = await http.get('${icingaUrl}monitoring/list/hosts?host=${host.getData('name')}&modifyFilter=1&format=json', headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      if (jsonData.length == 1) {
        host.update(jsonData[0]);
      } else {
        throw Exception("host not found");
      }
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load host, ${response.request.method} ${response.request.url} ${response.statusCode} ${response.body}');
    }
  }

  Future<void> checkUpdate() async {
    Duration diff = DateTime.now().difference(this.lastUpdate);
    if (!this.fetchedAllHosts | (diff.inSeconds > 60)) {
      await this.fetch();
    }
  }

  Future<Collection<Host>> getAll() async {
    await this.checkUpdate();

    List<Host> l = new List();
    this.hosts.forEach((name, host) => l.add(host));

    var m = new Collection<Host>(l);
    return m.orderBy((host) => int.parse(host.getData('state')) * -1).thenBy((host) => host.getName().toLowerCase()).thenBy((host) => host.getData('last_state_change')).toCollection();
  }

  Future<Collection<Host>> getAllWithProblems() async {
    await this.checkUpdate();

    List<Host> l = new List();
    this.hosts.forEach((name, host) => l.add(host));

    var m = new Collection<Host>(l);
    return m.where((host) => host.getData('state') != "0").orderBy((host) => int.parse(host.getData('state')) * -1).thenBy((host) => host.getData('last_state_change')).toCollection();
  }

  Future<Host> getHost(String hostName) async {
    await this.checkUpdate();

    if (this.hosts.containsKey(hostName)) {
      return this.hosts[hostName];
    }
    return null;
  }
}
