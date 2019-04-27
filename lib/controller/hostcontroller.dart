import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:mobilemon/models/host.dart';
import 'package:queries/collections.dart';

class HostController {
  Map<String, Host> hosts = new Map();

  Future fetchHost() async {
    final headers = Map<String, String>();
    final auth = base64Encode(utf8.encode("demo:demo"));
    headers['Authorization'] = "Basic $auth";
    headers['Accept'] = "application/json";

    final response = await http.get('https://www.icinga.com/demo/monitoring/list/hosts?format=json', headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      jsonData.forEach((item) {
        if (this.hosts.containsKey(item['host_name'])) {
          this.hosts[item['host_name']].update(item);
        } else {
          this.hosts[item['host_name']] = Host.fromJson(item);
        }
      });
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load host, code ${response.statusCode}');
    }
  }

  Future<Collection<Host>> getHosts() async {
    if (this.hosts.length < 1) {
      await this.fetchHost();
    }

    List<Host> l = new List();
    this.hosts.forEach((name, host) => l.add(host));

    var m = new Collection<Host>(l);
    return m.where((host) => host.getData('host_state') != "3").orderBy((host) => int.parse(host.getData('host_state')) * -1).thenBy((host) => host.getData('host_last_state_change')).toCollection();
  }
}
