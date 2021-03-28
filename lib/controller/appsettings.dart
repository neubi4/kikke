import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:kikke/controller/service_locator.dart';
import 'package:kikke/models/instancesettings.dart';
import 'package:kikke/storage/unsupported.dart' if (dart.library.io) "package:kikke/storage/app.dart" if (dart.library.js) "package:kikke/storage/web.dart";

import 'instancecontroller.dart';

class AppSettings {
  InstanceSettings instances;
  ThemeMode themeMode;
  String proxy;

  final storage = StorageProvider.getStorage();

  static const String field_instances = 'instances';
  static const String field_thememode = 'thememode';
  static const String field_proxy = 'proxy';

  Future loadDataFromProvider() async {
    String jsonString = await storage.read(key: AppSettings.field_instances);
    if (jsonString == null) {
      jsonString = "[]";
    }
    List<dynamic> json = jsonDecode(jsonString);
    this.instances = InstanceSettings.fromJson(json);

    String themeModeString = await storage.read(key: AppSettings.field_thememode);
    this.themeMode = this.getThemeMode(themeModeString);

    this.proxy = await storage.read(key: AppSettings.field_proxy);
    if(this.proxy == null) {
      this.proxy = '';
    }
  }

  ThemeMode getThemeMode(String themeModeString) {
    switch(themeModeString) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
        break;
      case 'ThemeMode.light':
        return ThemeMode.light;
        break;
    }

    return ThemeMode.system;
  }

  String getThemeModeString(ThemeMode themeMode) {
    return themeMode.toString();
  }

  Future saveThemeMode(ThemeMode themeMode) async {
    this.themeMode = themeMode;
    String themeModeString = this.getThemeModeString(themeMode);
    await storage.write(key: AppSettings.field_thememode, value: themeModeString);
  }

  String getProxy() {
    return this.proxy;
  }

  Future saveProxy(String proxy) async {
    this.proxy = proxy;
    await storage.write(key: AppSettings.field_proxy, value: proxy);

    await this.save();
  }

  Future saveData(String id, String name, String url, String username, String password) async {
    InstanceSetting i = InstanceSetting(id, name, url, username, password);
    InstanceSetting alreadyInList = this.getById(id);
    if (alreadyInList != null) {
      this.instances.instances.remove(alreadyInList);
    }
    this.instances.instances.add(i);

    this.save();
  }

  InstanceSetting getById(String id) {
    InstanceSetting i;
    this.instances.instances.forEach((instance) {
      if (instance.id == id) {
        i = instance;
      }
    });

    return i;
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

    dio.Dio d = dio.Dio();
    (d.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.findProxy = (uri) {
        if(this.proxy != '') {
          Uri uri = Uri.parse(this.proxy);
          return "PROXY ${uri.host}:${uri.port}";
        }
        return 'DIRECT';
      };
    };

    final dio.Response response = await d.get('${icingaUrl}monitoring/list/hosts?limit=1&format=json', options: dio.Options(
      headers: headers,
      responseType: dio.ResponseType.plain,
      sendTimeout: 3000,
      receiveTimeout: 60000,
    ));

    if (response.statusCode == 401) {
      throw Exception('Status Code 401 Unauthorized!');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to load, ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}');
    }
  }
}
