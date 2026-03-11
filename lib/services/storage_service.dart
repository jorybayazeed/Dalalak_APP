import 'package:get_storage/get_storage.dart';

class StorageService {

  static final GetStorage _storage = GetStorage();

  static const String _keyIsSignedIn = 'is_signed_in';
  static const String _keyUserType = 'user_type';
  static const String _keyUserId = 'user_id';

  static Future<void> init() async {
    await GetStorage.init();
  }

  static bool get isSignedIn => _storage.read(_keyIsSignedIn) ?? false;

  static String? get userType => _storage.read(_keyUserType);

  static String? get userId => _storage.read(_keyUserId);

  static Future<void> setSignedIn(bool value) async {
    await _storage.write(_keyIsSignedIn, value);
  }

  static Future<void> setUserType(String? type) async {
    if (type == null) {
      await _storage.remove(_keyUserType);
    } else {
      await _storage.write(_keyUserType, type);
    }
  }

  static Future<void> setUserId(String? id) async {
    if (id == null) {
      await _storage.remove(_keyUserId);
    } else {
      await _storage.write(_keyUserId, id);
    }
  }

  static Future<void> clearAll() async {
    await _storage.remove(_keyIsSignedIn);
    await _storage.remove(_keyUserType);
    await _storage.remove(_keyUserId);
  }
  
}

