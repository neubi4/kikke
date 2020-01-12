import 'dart:async';
import 'package:mobilemon/controller/icingacontroller.dart';

import 'package:mobilemon/models/host.dart';
import 'package:queries/collections.dart';

import 'instancecontroller.dart';

class HostController implements IcingaObjectController {
  InstanceController controller;

  HostController({this.controller});

  Future fetch() async {
    List<Future> futures = [];
    this.controller.instances.forEach((instance) {
      futures.add(instance.fetchHosts());
    });

    await Future.wait(futures);
  }

  Future<void> checkUpdate() async {
    List<Future> futures = [];
    this.controller.instances.forEach((instance) {
      futures.add(instance.checkUpdateHosts());
    });

    await Future.wait(futures);
  }

  Future<Collection<Host>> getAll() async {
    await this.checkUpdate();

    List<Host> l = new List();
    this.controller.instances.forEach((instance) {
      instance.hosts.forEach((name, hosts) => l.add(hosts));
    });

    var m = new Collection<Host>(l);
    return m
        .orderBy((host) => int.parse(host.getData('state')) * -1)
        .thenBy((host) => host.getName().toLowerCase())
        .thenBy((host) => host.getData('last_state_change'))
        .toCollection();
  }

  Future<Collection<Host>> getAllWithProblems() async {
    await this.checkUpdate();

    List<Host> l = new List();
    this.controller.instances.forEach((instance) {
      instance.hosts.forEach((name, hosts) => l.add(hosts));
    });

    var m = new Collection<Host>(l);
    return m
        .where((host) => host.getData('state') != "0")
        .orderBy((host) => int.parse(host.getData('state')) * -1)
        .thenBy((host) => host.getData('last_state_change'))
        .toCollection();
  }
}
