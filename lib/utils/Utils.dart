import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gaanap_admin_new/services/session_controller/session_controller.dart';

import '../config/routes/routes_name.dart';
import '../services/storage/local_storage.dart';

void showToast(String msg) {
  Fluttertoast.showToast(
    msg:msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black87,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

Future<void> logout(BuildContext context) async {
  final localStorage = LocalStorage();
final sessionController = SessionController();
  try {
    await localStorage.deleteData('user');
    await localStorage.deleteData('isLogin');
    await localStorage.deleteData('get_game_data');
    await sessionController.clearUser();

    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        RoutesName.splashScreen,
            (route) => false, // remove all previous routes
      );
    }
  } catch (e) {
    debugPrint('Logout error: $e');
    // Optionally still navigate or show error
  }
}