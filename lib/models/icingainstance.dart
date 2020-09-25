import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:kikke/models/icingaobject.dart';
import 'package:kikke/models/service.dart';

import '../exceptions.dart';
import 'downtime.dart';
import 'host.dart';

class IcingaInstance {
  String name;
  String url;
  String username;
  String password;

  Map<String, Service> services = new Map();
  Map<String, Host> hosts = new Map();
  Map<String, Downtime> downtimes = new Map();

  bool fetchedAllServices = false;
  bool fetchedAllHosts = false;
  bool fetchedAllDowntimes = false;
  DateTime lastUpdateServices = new DateTime(1970);
  DateTime lastUpdateHosts = new DateTime(1970);
  DateTime lastUpdateDowntimes = new DateTime(1970);

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

    final dio.Response response = await dio.Dio().get('${icingaUrl}monitoring/list/hosts?limit=1&format=json', options: dio.Options(
      headers: headers,
      responseType: dio.ResponseType.plain,
      sendTimeout: 3000,
      receiveTimeout: 60000,
    ));

    if (response.statusCode == 401) {
      throw Exception('Status Code 401 Unauthorized!');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to load, ${response.statusCode} ${response.request.method} ${response.request.uri}');
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

    final dio.Response response = await dio.Dio().get('${icingaUrl}monitoring/list/services?format=json&limit=10000', options: dio.Options(
      headers: headers,
      responseType: dio.ResponseType.plain,
      sendTimeout: 3000,
      receiveTimeout: 60000,
    ));

    if (response.statusCode == 200) {
      var jsonData = (json.decode(response.data) as List);

      for (var i = 0; i < jsonData.length; i++) {
        await this.parseServiceRow(jsonData[i]);
      }

      this.fetchedAllServices = true;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load services, ${response.request.method} ${response.request.uri} ${response.statusCode} ${response.data}');
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

  Future removeAcknowledge(IcingaObject iobject) async {
    final headers = this.getDefaultHeaders();
    String icingaUrl = this.getUrl();

    String url = "";
    if(iobject is Service) {
      url = "monitoring/service/show?host=${iobject.host.getName()}&service=${iobject.getName()}";
    } else {
      url = "monitoring/host/show?host=${iobject.getName()}";
    }

    print("${this.name} remove ack ${url}");

    Map<String, dynamic> mapData = {
      "formUID": "IcingaModuleMonitoringFormsCommandObjectRemoveAcknowledgementCommandForm",
      "btn_submit": "Remove acknowledgement",
    };

    FormData formData = new FormData.fromMap(mapData);
    print(mapData);

    String msg;

    try {
      final dio.Response response = await dio.Dio().post('${icingaUrl}${url}', data: formData, options: dio.Options(
        headers: headers,
        responseType: dio.ResponseType.plain,
        sendTimeout: 3000,
        receiveTimeout: 60000,
      ));

      var jsonData = json.decode(response.data);
      print(jsonData);
      if(jsonData['status'] == 'fail') {
        throw Exception(response.data.toString());
      }

    } on DioError catch(e) {
      try {
        var jsonData = json.decode(e.response.data);
        msg = jsonData['message'];
      } on Exception catch(ee) {
        throw Exception(e.response.data);
      }
      throw Exception(msg);
    }
  }

  Future acknowledge(IcingaObject iobject, String comment, {bool persistent = false, bool expire = false, bool sticky = false, bool notify = false, DateTime expireTime}) async {
    final headers = this.getDefaultHeaders();
    String icingaUrl = this.getUrl();

    String url = "";
    if(iobject is Service) {
      url = "monitoring/service/acknowledge-problem?host=${iobject.host.getName()}&service=${iobject.getName()}";
    } else {
      url = "monitoring/host/acknowledge-problem?host=${iobject.getName()}";
    }

    print("${this.name} ack ${url}");

    Map<String, dynamic> mapData = {
      "comment": comment,
      "expire": expire ? 1 : 0,
      "notify": notify ? 1 : 0,
      "persistent": persistent ? 1 : 0,
      "sticky": sticky ? 1 : 0,
    };

    if(expire) {
      mapData["expire_time"] = DateFormat('yyyy-MM-ddThh:mm:ss').format(expireTime);
    }

    FormData formData = new FormData.fromMap(mapData);

    String msg;

    try {
      final dio.Response response = await dio.Dio().post('${icingaUrl}${url}', data: formData, options: dio.Options(
        headers: headers,
        responseType: dio.ResponseType.plain,
        sendTimeout: 3000,
        receiveTimeout: 60000,
      ));

      var jsonData = json.decode(response.data);
      print(jsonData);
      if(jsonData['status'] == 'fail') {
        throw Exception(response.data.toString());
      }

    } on DioError catch(e) {
      try {
        var jsonData = json.decode(e.response.data);
        msg = jsonData['message'];
      } on Exception catch(ee) {
        throw Exception(e.response.data);
      }
      throw Exception(msg);
    }
  }

  Future scheduleDowmtime(IcingaObject iobject, String comment, DateTime start, DateTime end, {String type = "fixed"}) async {
    final headers = this.getDefaultHeaders();
    String icingaUrl = this.getUrl();

    String url = "";
    if(iobject is Service) {
      url = "monitoring/service/schedule-downtime?host=${iobject.host.getName()}&service=${iobject.getName()}";
    } else {
      url = "monitoring/host/schedule-downtime?host=${iobject.getName()}";
    }

    print("${this.name} ack ${url}");

    Map<String, dynamic> mapData = {
      "comment": comment,
      "start": DateFormat('yyyy-MM-ddTHH:mm:ss').format(start),
      "end": DateFormat('yyyy-MM-ddTHH:mm:ss').format(end),
      "type": type,
    };

    print(mapData);

    FormData formData = new FormData.fromMap(mapData);

    String msg;

    try {
      final dio.Response response = await dio.Dio().post('${icingaUrl}${url}', data: formData, options: dio.Options(
        headers: headers,
        responseType: dio.ResponseType.plain,
        sendTimeout: 3000,
        receiveTimeout: 60000,
      ));

      var jsonData = json.decode(response.data);
      print(jsonData);
      if(jsonData['status'] == 'fail') {
        throw Exception(response.data.toString());
      }

    } on DioError catch(e) {
      try {
        var jsonData = json.decode(e.response.data);
        msg = jsonData['message'];
      } on Exception catch(ee) {
        throw Exception(e.response.data);
      }
      throw Exception(msg);
    }
  }

  Future fetchHosts() async {
    this.lastUpdateHosts = DateTime.now();

    final headers = this.getDefaultHeaders();

    print("${this.name} fetching hosts");

    String icingaUrl = this.getUrl();

    final dio.Response response = await dio.Dio().get('${icingaUrl}monitoring/list/hosts?limit=10000&format=json', options: dio.Options(
      headers: headers,
      responseType: dio.ResponseType.plain,
      sendTimeout: 3000,
      receiveTimeout: 60000,
    ));

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.data);

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
      throw Exception('Failed to load host, ${response.request.method} ${response.request.uri} ${response.statusCode} ${response.data}');
    }
  }

  Future<Host> getHost(String hostName) async {
    await this.checkUpdateHosts();

    if (this.hosts.containsKey(hostName)) {
      return this.hosts[hostName];
    }
    return null;
  }

  Future fetchDowntimes() async {
    this.lastUpdateDowntimes = DateTime.now();

    final headers = this.getDefaultHeaders();

    print("${this.name} fetching downtimes");

    String icingaUrl = this.getUrl();

    final dio.Response response = await dio.Dio().get('${icingaUrl}monitoring/list/downtimes?limit=10000&format=json', options: dio.Options(
      headers: headers,
      responseType: dio.ResponseType.plain,
      sendTimeout: 3000,
      receiveTimeout: 60000,
    ));

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.data);

      jsonData.forEach((item) {
        if (this.downtimes.containsKey(item['name'])) {
          this.downtimes[item['name']].update(item);
        } else {
          this.downtimes[item['name']] = Downtime.fromJson(item, this);
        }

        this.fetchedAllDowntimes = true;
      });
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load downtimes, ${response.request.method} ${response.request.uri} ${response.statusCode} ${response.data}');
    }
  }

  Future<Downtime> getDowntime(String downtimeName) async {
    await this.checkUpdateHosts();

    if (this.downtimes.containsKey(downtimeName)) {
      return this.downtimes[downtimeName];
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

  Future<void> checkUpdateDowntimes() async {
    Duration diff = DateTime.now().difference(this.lastUpdateDowntimes);
    if (!this.fetchedAllDowntimes | (diff.inSeconds > 60)) {
      await this.fetchDowntimes();
    }
  }
}
