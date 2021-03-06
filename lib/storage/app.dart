import 'dart:io';

import 'storage_interface.dart';
import 'shared_pref.dart' as Shared_Pref;
import 'app_secure.dart' as App_Secure;

class StorageProvider {
  static StorageInterface getStorage() {
    if(Platform.isAndroid || Platform.isIOS) {
      return App_Secure.Storage();
    }
    return Shared_Pref.Storage();
  }
}
