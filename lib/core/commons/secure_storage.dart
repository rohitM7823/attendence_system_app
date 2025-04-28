import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  static SecureStorage? _instance;

  static SecureStorage get instance {
    _instance ??= SecureStorage._();
    return _instance!;
  }

  static const String _userDeviceIdentifier = "IDENTIFIER";
  static const String _userDeviceStatus = "DEVICE_STATUS";

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> setDeviceIdentifier(String value) async {
    await _storage.write(key: _userDeviceIdentifier, value: value);
  }

  Future<String?> get deviceIdentifier async {
    return await _storage.read(key: _userDeviceIdentifier);
  }

  Future<void> deleteDeviceIdentifier() async {
    await _storage.delete(key: _userDeviceIdentifier);
  }

  Future<void> setDeviceStatus(String value) async {
    await _storage.write(key: _userDeviceStatus, value: value);
  }

  Future<String?> get deviceStatus async {
    return await _storage.read(key: _userDeviceStatus);
  }

  Future<void> deleteDeviceStatus() async {
    await _storage.delete(key: _userDeviceStatus);
  }
}
