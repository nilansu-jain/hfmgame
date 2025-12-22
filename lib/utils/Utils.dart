import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

void logout(BuildContext context){
  LocalStorage localStorage = LocalStorage();
  localStorage.deleteData('user').then((value){
    localStorage.deleteData('isLogin').then((value) {
      localStorage.deleteData("get_game_data").then((value) {
        Navigator.of(context).pushNamed(RoutesName.splashScreen);

      });

    });
  });
}