import 'dart:async';
import 'package:kikke/controller/icingacontroller.dart';

import 'package:kikke/models/host.dart';

import 'instancecontroller.dart';

class HostController implements IcingaObjectController {
  InstanceController controller;

  HostController({this.controller});

  String getType() {
    return "Host";
  }

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

  Future<List<Host>> getAll() async {
    await this.checkUpdate();

    List<Host> l = [];
    this.controller.instances.forEach((instance) {
      instance.hosts.forEach((name, hosts) => l.add(hosts));
    });

    l.sort();
    return l;
  }

  Future<List<Host>> getAllWithProblems() async {
    await this.checkUpdate();

    List<Host> l = [];
    this.controller.instances.forEach((instance) {
      instance.hosts.forEach((name, hosts) => l.add(hosts));
    });

    l = l.where((host) => host.getData('state') != "0").toList();
    l.sort();
    return l;
  }

  Future<List<Host>> getAllSearch(String search) async {
    search = search.toLowerCase();
    List<Host> l = new List();
    this.controller.instances.forEach((instance) {
      instance.hosts.forEach((name, host) {
        if (host.getAllNames().toLowerCase().contains(search)) {
          l.add(host);
        }
      });
    });

    l.sort();
    return l;
  }
}
