import 'dart:async';
import 'package:kikke/controller/icingacontroller.dart';
import 'package:kikke/models/downtime.dart';
import 'package:kikke/models/icingaobject.dart';

import 'package:queries/collections.dart';

import 'instancecontroller.dart';

class DowntimesController implements IcingaObjectController {
  InstanceController controller;

  DowntimesController({this.controller});

  String getType() {
    return "Downtimes";
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

    List<Downtime> l = new List();
    this.controller.instances.forEach((instance) {
      instance.downtimes.forEach((name, downtime) => l.add(downtime));
    });

    var m = new Collection<Downtime>(l);
    return m
        .orderBy((downtime) => int.parse(downtime.getData('last_state_change')))
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
        .orderBy((downtime) => int.parse(downtime.getData('last_state_change')))
        .thenBy((downtime) => downtime.getName().toLowerCase())
        .toCollection();
  }

  Future<Collection<IcingaObject>> getAllWithProblems() {
    // TODO: implement getAllWithProblems
    throw UnimplementedError();
  }
}
