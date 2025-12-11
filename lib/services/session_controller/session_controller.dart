import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/user/user_model.dart';

class SessionController {
  static final SessionController _session = SessionController._internal();

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  UserModel userModel = UserModel();
  bool isLogin = false;

  SessionController._internal();

  factory SessionController() {
    return _session;
  }

  // -----------------------------
  // Save User Data Securely
  // -----------------------------
  Future<void> saveUserPreference(UserModel user) async {
    try {
      await secureStorage.write(key: 'user', value: jsonEncode(user));
      await secureStorage.write(key: 'isLogin', value: 'true');
      debugPrint("User saved securely");
    } catch (e) {
      debugPrint("Error saving secure user: $e");
    }
  }

  // -----------------------------
  // Get User Data Securely
  // -----------------------------
  Future<void> getUserPreference() async {
    try {
      String? userData = await secureStorage.read(key: 'user');
      String? loginFlag = await secureStorage.read(key: 'isLogin');

      if (kDebugMode) {
        debugPrint("Fetched secure user data: $userData");
        debugPrint("Fetched secure loginFlag: $loginFlag");
      }

      if (userData != null && userData.isNotEmpty) {
        userModel = UserModel.fromJson(jsonDecode(userData));
      }

      isLogin = loginFlag == 'true';

    } catch (e) {
      debugPrint("Error reading secure user: $e");
    }
  }

  // -----------------------------
  // Clear User Data (Logout)
  // -----------------------------
  Future<void> clearUser() async {
    await secureStorage.delete(key: 'user');
    await secureStorage.delete(key: 'isLogin');
    isLogin = false;
    userModel = UserModel();
    debugPrint("User session cleared");
  }
}
