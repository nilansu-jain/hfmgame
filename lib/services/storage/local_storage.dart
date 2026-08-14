import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // Static shared instance
  static final Future<SharedPreferences> _prefsFuture =
  SharedPreferences.getInstance();

  // Instance methods (if you still use them somewhere)
  Future<bool> addData(String key, String value) async {
    final prefs = await _prefsFuture;
    return await prefs.setString(key, value);
  }

  Future<dynamic> getData(String key) async {
    final prefs = await _prefsFuture;
    return prefs.getString(key);
  }

  Future<bool> deleteData(String key) async {
    final prefs = await _prefsFuture;
    return await prefs.remove(key);
  }

  /// Save model
  static Future<void> saveModel(String key, dynamic model) async {
    final prefs = await _prefsFuture;
    final jsonString = jsonEncode(model);
    await prefs.setString(key, jsonString);
  }

  /// Read model
  static Future<Map<String, dynamic>?> readModel(String key) async {
    final prefs = await _prefsFuture;
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;

    return jsonDecode(jsonString);
  }

  /// Delete model
  static Future<bool> delete(String key) async {
    final prefs = await _prefsFuture;
    await prefs.remove(key);
    return true;
  }
}