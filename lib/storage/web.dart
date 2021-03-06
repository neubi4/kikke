import 'storage_interface.dart';
import 'shared_pref.dart' as Shared_Pref;

class StorageProvider {
  static StorageInterface getStorage() {
    return Shared_Pref.Storage();
  }
}
