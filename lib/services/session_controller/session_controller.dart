import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user/user_model.dart';

class SessionController {
  static final SessionController _session = SessionController._internal();

  // Use SharedPreferences instead of secure storage
  static final Future<SharedPreferences> _prefsFuture =
  SharedPreferences.getInstance();

  UserModel userModel = UserModel();
  bool isLogin = false;

  SessionController._internal();

  factory SessionController() {
    return _session;
  }

  // -----------------------------
  // Save User Data
  // -----------------------------
  Future<void> saveUserPreference(UserModel user) async {
    try {
      final prefs = await _prefsFuture;
      await prefs.setString('user', jsonEncode(user));
      await prefs.setString('isLogin', 'true');
      debugPrint("User saved");
    } catch (e) {
      debugPrint("Error saving user: $e");
    }
  }

  // -----------------------------
  // Get User Data
  // -----------------------------
  Future<void> getUserPreference() async {
    try {
      final prefs = await _prefsFuture;
      final userData = prefs.getString('user');
      final loginFlag = prefs.getString('isLogin');

      if (kDebugMode) {
        debugPrint("Fetched user data: $userData");
        debugPrint("Fetched loginFlag: $loginFlag");
      }

      if (userData != null && userData.isNotEmpty) {
        userModel = UserModel.fromJson(jsonDecode(userData));
      }

      isLogin = loginFlag == 'true';
    } catch (e) {
      debugPrint("Error reading user: $e");
    }
  }

  // -----------------------------
  // Clear User Data (Logout)
  // -----------------------------
  Future<void> clearUser() async {
    try {
      final prefs = await _prefsFuture;
      await prefs.remove('user');
      await prefs.remove('isLogin');
      isLogin = false;
      userModel = UserModel();
      debugPrint("User session cleared");
    } catch (e) {
      debugPrint("Error clearing user: $e");
    }
  }
}