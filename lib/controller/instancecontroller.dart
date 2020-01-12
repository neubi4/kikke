import 'package:mobilemon/models/icingainstance.dart';

class InstanceController {
  List<IcingaInstance> instances = [];

  void addInstance(IcingaInstance instance) {
    this.instances.add(instance);
  }

  void reset() {
    this.instances.clear();
  }
}
