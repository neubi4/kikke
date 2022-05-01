import 'package:kikke/controller/icingacontroller.dart';
import 'package:kikke/controller/instancecontroller.dart';
import 'package:kikke/models/host.dart';
import 'package:kikke/models/service.dart';

class ServiceController implements IcingaObjectController {
  InstanceController controller;

  ServiceController({this.controller});

  String getType() {
    return "Service";
  }

  Future fetch() async {
    List<Future> futures = [];
    this.controller.instances.forEach((instance) {
      futures.add(instance.fetchServices());
    });

    await Future.wait(futures);
  }

  Future<void> checkUpdate() async {
    List<Future> futures = [];
    this.controller.instances.forEach((instance) {
      futures.add(instance.checkUpdateServices());
    });

    await Future.wait(futures);
  }

  Future<List<Service>> getServicesForHost(Host host) async {
    await this.checkUpdate();

    List<Service> l = new List();
    this.controller.instances.forEach((instance) {
      instance.services.forEach((name, service) => l.add(service));
    });

    l = l.where((service) => service.host == host).toList();
    l.sort();
    return l;
  }

  Future<List<Service>> getAll() async {
    await this.checkUpdate();

    List<Service> l = new List();
    this.controller.instances.forEach((instance) {
      instance.services.forEach((name, service) => l.add(service));
    });

    l.sort();
    return l;
  }

  Future<List<Service>> getAllWithProblems() async {
    await this.checkUpdate();

    List<Service> l = new List();
    this.controller.instances.forEach((instance) {
      instance.services.forEach((name, service) => l.add(service));
    });

    l = l.where((host) => host.getData('state') != "0").toList();
    l.sort();
    return l;
  }

  List<Service> getAllForHost(Host host) {
    List<Service> l = new List();
    this.controller.instances.forEach((instance) {
      instance.services.forEach(
          (name, service) => service.host == host ? l.add(service) : false);
    });

    l.sort();
    return l;
  }

  List<Service> getWithStatus(Host host, String state) {
    var l = this.getAllForHost(host);

    l = l.where((host) => host.getData('state') == state).toList();
    return l;
  }

  Future<List<Service>> getAllSearch(String search) async {
    search = search.toLowerCase();
    List<Service> l = new List();
    this.controller.instances.forEach((instance) {
      instance.services.forEach((name, service) {
        if (service.getAllNames().toLowerCase().contains(search) ||
            service.host.getAllNames().toLowerCase().contains(search)) {
          l.add(service);
        }
      });
    });

    l.sort();
    return l;
  }
}
