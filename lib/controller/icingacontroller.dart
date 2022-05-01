import 'package:kikke/models/icingaobject.dart';
import 'package:queries/collections.dart';

abstract class IcingaObjectController {
  String getType();
  Future<List<IcingaObject>> getAll();
  Future<List<IcingaObject>> getAllSearch(String search);
  Future<List<IcingaObject>> getAllWithProblems();
  Future fetch();
}
