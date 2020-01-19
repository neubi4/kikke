import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kikke/controller/service_locator.dart';
import 'package:kikke/models/instancesettings.dart';
import 'package:http/http.dart' as http;

import 'instancecontroller.dart';

class AppSettings {
  InstanceSettings instances;

  final storage = new FlutterSecureStorage();

  static const String field_instances = 'instances';

  Future loadDataFromProvider() async {
    String jsonString = await storage.read(key: AppSettings.field_instances);
    if (jsonString == null) {
      jsonString = "[]";
    }
    List<dynamic> json = jsonDecode(jsonString);
    this.instances = InstanceSettings.fromJson(json);
  }

  Future saveData(String name, String url, String username, String password) async {
    InstanceSetting i = InstanceSetting(name, url, username, password);
    InstanceSetting alreadyInList = this.getByName(name);
    if (alreadyInList != null) {
      this.instances.instances.remove(alreadyInList);
    }
    this.instances.instances.add(i);

    this.save();
  }

  InstanceSetting getByName(String name) {
    InstanceSetting i;
    this.instances.instances.forEach((instance) {
      if (instance.name == name) {
        i = instance;
      }
    });

    return i;
  }

  Future save() async {
    String jsonString = jsonEncode(this.instances);
    await storage.write(key: AppSettings.field_instances, value: jsonString);
    await this.loadDataFromProvider();

    InstanceController controller = getIt.get<InstanceController>();
    controller.loadFromInstances(this.instances.instances);
  }

  Future delete(InstanceSetting instance) async {
    this.instances.instances.remove(instance);
    await this.save();
  }

  Future checkData(String url, String username, String password) async {
    final headers = Map<String, String>();
    final auth = base64Encode(utf8.encode("$username:$password"));
    String icingaUrl = Uri.parse(url).toString();
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
}
