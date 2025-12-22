import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage{

  final storage = const FlutterSecureStorage();
  static const _storage = FlutterSecureStorage();

  Future<bool>  addData(String key, String value) async{
    await storage.write(key: key, value: value);
    return true;
  }

  Future<dynamic> getData(String key) async{
    return await storage.read(key: key);
  }

  Future<bool> deleteData(String key) async{
    await storage.delete(key: key);
    return true;
  }

  /// Save model
  static Future<void> saveModel(String key, dynamic model) async {
    final jsonString = jsonEncode(model);
    await _storage.write(key: key, value: jsonString);
  }

  /// Read model
  static Future<Map<String, dynamic>?> readModel(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;

    return jsonDecode(jsonString);
  }

  /// Delete model
  static Future<bool> delete(String key) async {
    await _storage.delete(key: key);
    return true;
  }
}
