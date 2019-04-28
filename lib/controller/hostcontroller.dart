import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:mobilemon/models/host.dart';
import 'package:queries/collections.dart';

class HostController {
  Map<String, Host> hosts = new Map();
  bool fetchedAllHosts = false;
  DateTime lastUpdate = new DateTime(1970);

  Future fetchHosts() async {
    final headers = Map<String, String>();
    final auth = base64Encode(utf8.encode("demo:demo"));
    headers['Authorization'] = "Basic $auth";
    headers['Accept'] = "application/json";

    print("loading hosts");

    final response = await http.get('https://www.icinga.com/demo/monitoring/list/hosts?limit=10000&format=json', headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      jsonData.forEach((item) {
        if (this.hosts.containsKey(item['host_name'])) {
          this.hosts[item['host_name']].update(item);
        } else {
          this.hosts[item['host_name']] = Host.fromJson(item);
        }

        this.fetchedAllHosts = true;
        this.lastUpdate = DateTime.now();
      });
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load host, ${response.request.method} ${response.request.url} ${response.statusCode} ${response.body}');
    }
  }

  Future<void> checkUpdate() async {
    Duration diff = DateTime.now().difference(this.lastUpdate);
    if (!this.fetchedAllHosts | (diff.inSeconds > 60)) {
      await this.fetchHosts();
    }
  }

  Future<Collection<Host>> getHosts() async {
    await this.checkUpdate();

    List<Host> l = new List();
    this.hosts.forEach((name, host) => l.add(host));

    var m = new Collection<Host>(l);
    return m.where((host) => host.getData('host_state') != "3").orderBy((host) => int.parse(host.getData('host_state')) * -1).thenBy((host) => host.getData('host_last_state_change')).toCollection();
  }

  Future<Collection<Host>> getProblemHosts() async {
    await this.checkUpdate();

    List<Host> l = new List();
    this.hosts.forEach((name, host) => l.add(host));

    var m = new Collection<Host>(l);
    return m.where((host) => host.getData('host_state') != "0").orderBy((host) => int.parse(host.getData('host_state')) * -1).thenBy((host) => host.getData('host_last_state_change')).toCollection();
  }

  Future<Host> getHost(String hostName) async {
    await this.checkUpdate();

    if (this.hosts.containsKey(hostName)) {
      return this.hosts[hostName];
    }
    return null;
  }
}
