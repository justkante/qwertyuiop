import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage implements SecureStorageBase {
  static FlutterSecureStorage storage = const FlutterSecureStorage(
    iOptions: IOSOptions(),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Future<void> saveData(String key, String value) async {
    await storage.write(key: key, value: value);
    log("saved");
  }

  @override
  Future<String> readData(String key) async {
    return await storage.read(key: key) ?? "";
  }

  @override
  Future<bool> containsData(String key) async {
    return await storage.containsKey(key: key);
  }

  @override
  Future<void> deleteData(String key) async {
    await storage.delete(key: key);
  }

  @override
  Future<void> deleteAllData() async {
    await storage.deleteAll();
  }

  @override
  Future<Map<String, String>> readAllData() async {
    return await storage.readAll();
  }
}

abstract class SecureStorageBase {
  Future<void> saveData(String key, String value);

  Future<String> readData(String key);

  Future<Map<String, String>> readAllData();

  Future<bool> containsData(String key);

  Future<void> deleteData(String key);

  Future<void> deleteAllData();
}
