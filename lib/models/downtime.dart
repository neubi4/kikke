import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kikke/models/icingaobject.dart';

import 'icingainstance.dart';

class Downtime with IcingaObject implements Comparable {
  String name;
  String address;
  Map<String, dynamic> data;

  IcingaInstance instance;

  Downtime({this.name, this.data, this.instance});

  factory Downtime.fromJson(Map<String, dynamic> json, IcingaInstance instance) {
    return Downtime(
      name: json['name'],
      data: json,
      instance: instance,
    );
  }

  void update(Map<String, dynamic> json) {
    this.name = json['name'];
    this.data.addAll(json);
  }

  String getName() {
    return this.getRawData('name');
  }

  String getDisplayName() {
    if(this.getRawData('service_description') == null) {
      return this.getRawData('host_name');
    }

    return "${this.getRawData('service_description')} on ${this.getRawData('host_name')}";
  }

  String getAllNames() {
    return "${this.getDisplayName()}";
  }

  Icon getIcon() {
    return Icon(Icons.access_time);
  }

  int getState() {
    return 0;
  }

  IcingaObject getParent() {
    if(this.getRawData('service_description') == null) {
      //is host downtime
      if(this.instance.hosts.containsKey(this.getRawData('host_name'))) {
        return this.instance.hosts[this.getRawData('host_name')];
      }
    } else {
      if(this.instance.services.containsKey(this.getRawData('host_name') + this.getRawData('service_description'))) {
        return this.instance.services[this.getRawData('host_name') + this.getRawData('service_description')];
      }
    }
    
    //noting found?
    return null;
  }

  String getDescription(BuildContext context) {
    DateTime dateStart = DateTime.fromMillisecondsSinceEpoch(int.parse(this.getRawData('start')) * 1000);
    DateTime dateEnd = DateTime.fromMillisecondsSinceEpoch(int.parse(this.getRawData('end')) * 1000);

    String start = DateFormat.yMd(Localizations.localeOf(context).languageCode).add_jm().format(dateStart);
    String end = DateFormat.yMd(Localizations.localeOf(context).languageCode).add_jm().format(dateEnd);

    return "$start until $end, set by ${this.getRawData('author_name')} comment: ${this.getRawData('comment')}";
  }

  String getWebUrl() {
    return "${this.instance.getUrl()}monitoring/downtime/show?downtime_id=${this.getData('id')}";
  }

  @override
  int compareTo(other) {
    List<int> compares = [
      this.getRawDataAsInt('start').compareTo(other.getRawDataAsInt('start')),
      this.getName().toLowerCase().compareTo(other.getName().toLowerCase()),
    ];

    return this.compare(compares);
  }
}
