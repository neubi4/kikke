import 'package:mobilemon/models/icingaobject.dart';
import 'package:queries/collections.dart';

abstract class IcingaObjectController {
  Future<Collection<IcingaObject>> getAll();
  Future<Collection<IcingaObject>> getAllWithProblems();
  Future fetch();
}
