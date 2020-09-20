import 'package:kikke/models/icingaobject.dart';
import 'package:queries/collections.dart';

abstract class IcingaObjectController {
  String getType();
  Future<Collection<IcingaObject>> getAll();
  Future<Collection<IcingaObject>> getAllSearch(String search);
  Future<Collection<IcingaObject>> getAllWithProblems();
  Future fetch();
}
