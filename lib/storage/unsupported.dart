import 'storage_interface.dart';

class StorageProvider {
  static StorageInterface getStorage() {
    throw UnsupportedError("Platform not supported");
  }
}
