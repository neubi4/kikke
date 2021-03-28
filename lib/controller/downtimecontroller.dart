import 'dart:async';
import 'package:kikke/controller/icingacontroller.dart';
import 'package:kikke/models/downtime.dart';
import 'package:kikke/models/host.dart';
import 'package:kikke/models/icingaobject.dart';
import 'package:kikke/models/service.dart';

import 'package:queries/collections.dart';

import 'instancecontroller.dart';

class DowntimeController implements IcingaObjectController {
  InstanceController controller;

  DowntimeController({this.controller});

  String getType() {
    return "Downtime";
  }

  Future fetch() async {
    List<Future> futures = [];
    this.controller.instances.forEach((instance) {
      futures.add(instance.fetchDowntimes());
    });

    await Future.wait(futures);
  }

  Future<void> checkUpdate() async {
    List<Future> futures = [];
    this.controller.instances.forEach((instance) {
      futures.add(instance.checkUpdateDowntimes());
    });

    await Future.wait(futures);
  }

  Future<Collection<Downtime>> getAll() async {
    await this.checkUpdate();

    return this.getAllSync();
  }

  Collection<Downtime> getAllSync() {
    List<Downtime> l = new List();
    this.controller.instances.forEach((instance) {
      instance.downtimes.forEach((name, downtime) => l.add(downtime));
    });

    var m = new Collection<Downtime>(l);
    return m
        .orderBy((downtime) => int.parse(downtime.getRawData('start')))
        .thenBy((downtime) => downtime.getName().toLowerCase())
        .toCollection();
  }

  Future<Collection<Downtime>> getAllSearch(String search) async {
    search = search.toLowerCase();
    List<Downtime> l = new List();
    this.controller.instances.forEach((instance) {
      instance.downtimes.forEach((name, downtime) {
        if (downtime.getAllNames().toLowerCase().contains(search)) {
          l.add(downtime);
        }
      });
    });

    var m = new Collection<Downtime>(l);
    return m
        .orderBy((downtime) => int.parse(downtime.getRawData('start')))
        .thenBy((downtime) => downtime.getName().toLowerCase())
        .toCollection();
  }

  Future<Collection<Downtime>> getForObject(IcingaObject iobject) async {
    await this.checkUpdate();

    List<Downtime> l = new List();
    this.controller.instances.forEach((instance) {
      instance.downtimes.forEach((name, downtime) {
        if(iobject is Host) {
          if(downtime.getRawData('host_name') == iobject.getName()) {
            l.add(downtime);
          }
        } else if(iobject is Service) {
          if(downtime.getRawData('service_description') == iobject.getName() && downtime.getRawData('host_name') == iobject.host.getName()) {
            l.add(downtime);
          }
        }
      });
    });

    var m = new Collection<Downtime>(l);
    return m
        .orderBy((downtime) => int.parse(downtime.getRawData('start')))
        .thenBy((downtime) => downtime.getName().toLowerCase())
        .toCollection();
  }

  Future<Collection<IcingaObject>> getAllWithProblems() {
    // TODO: implement getAllWithProblems
    throw UnimplementedError();
  }
}
