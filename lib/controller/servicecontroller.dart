import 'dart:convert';

import 'package:mobilemon/controller/appsettings.dart';
import 'package:mobilemon/controller/hostcontroller.dart';
import 'package:mobilemon/controller/icingacontroller.dart';
import 'package:mobilemon/models/host.dart';
import 'package:mobilemon/models/service.dart';

import 'package:http/http.dart' as http;
import 'package:queries/collections.dart';

class ServiceController implements IcingaObjectController {
  AppSettings appSettings;

  Map<String, Service> services = new Map();
  bool fetchedAllServices = false;
  DateTime lastUpdate = new DateTime(1970);

  HostController hostController;

  ServiceController({this.appSettings, this.hostController});

  void setHostController(HostController hostController) {
    this.hostController = hostController;
  }

  Future fetch() async {
    final headers = Map<String, String>();
    final auth = await this.appSettings.getAuthData();
    headers['Authorization'] = "Basic $auth";
    headers['Accept'] = "application/json";

    print("fetching services");

    String icingaUrl = await this.appSettings.getIcingaUrl();

    final response = await http.get('${icingaUrl}monitoring/list/services?format=json&limit=10000', headers: headers);
    if (response.statusCode == 200) {
      var jsonData = (json.decode(response.body) as List);

      for (var i = 0; i < jsonData.length; i++) {
        await this.parseRow(jsonData[i]);
      }

      this.fetchedAllServices = true;
      this.lastUpdate = DateTime.now();

    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load services, ${response.request.method} ${response.request.url} ${response.statusCode} ${response.body}');
    }
  }

  Future parseRow(Map<String, dynamic> item) async {
    if (this.services.containsKey(item['host_name'] + item['service_description'])) {
      this.services[item['host_name'] + item['service_description']].update(item);
    } else {
      Host host = await this.hostController.getHost(item['host_name']);
      this.services[item['host_name'] + item['service_description']] = Service.fromJson(item, host, this);
    }
  }

  Future fetchServicesForHost(Host host) async {
    final headers = Map<String, String>();
    final auth = await this.appSettings.getAuthData();
    headers['Authorization'] = "Basic $auth";
    headers['Accept'] = "application/json";

    print("fetching services for host ${host.getData('name')}");

    String icingaUrl = await this.appSettings.getIcingaUrl();

    final response = await http.get('${icingaUrl}monitoring/list/services?host=${host.getData('name')}&modifyFilter=1&format=json', headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);      
      jsonData.forEach((item) async {
        if (this.services.containsKey(item['host_name'] + item['service_description'])) {
          this.services[item['host_name'] + item['service_description']].update(item);
        } else {
          this.services[item['host_name'] + item['service_description']] = Service.fromJson(item, host, this);
        }
      });
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load services, ${response.request.method} ${response.request.url} ${response.statusCode} ${response.body}');
    }
  }

  Future<void> checkUpdate() async {
    Duration diff = DateTime.now().difference(this.lastUpdate);
    if (!this.fetchedAllServices | (diff.inSeconds > 60)) {
      await this.fetch();
    }
  }

  Future<Collection<Service>> getServicesForHost(Host host) async {
    await this.checkUpdate();

    List<Service> l = new List();
    this.services.forEach((name, service) => l.add(service));
    
    var m = new Collection<Service>(l);
    return m.where((service) => service.host == host);
  }  
  
  Future<Collection<Service>> getAll() async {
    await this.checkUpdate();

    List<Service> l = new List();
    this.services.forEach((name, service) => l.add(service));
    
    var m = new Collection<Service>(l);
    return m.orderBy((service) => int.parse(service.getData('state')) * -1).thenBy((service) => service.getData('last_state_change')).toCollection();
  }

  Future<Collection<Service>> getAllWithProblems() async {
    await this.checkUpdate();

    List<Service> l = new List();
    this.services.forEach((name, service) => l.add(service));

    var m = new Collection<Service>(l);
    return m.where((service) => service.getData('state') != "0").orderBy((service) => int.parse(service.getData('state')) * -1).thenBy((service) => service.getData('last_state_change')).toCollection();
  }

  Collection<Service> getAllForHost(Host host) {
    List<Service> l = new List();
    this.services.forEach((name, service) => service.host == host ? l.add(service) : false);

    var m = new Collection<Service>(l);
    return m.where((service) => service.getData('state') != "0").orderBy((service) => int.parse(service.getData('state')) * -1).thenBy((service) => service.getData('last_state_change')).toCollection();
  }
}
