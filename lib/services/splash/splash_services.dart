import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/routes/routes_name.dart';
import '../session_controller/session_controller.dart';

class SplashServices{

  void isLogin(BuildContext context){

    SessionController().getUserPreference().then((value){
      debugPrint("${SessionController().isLogin}");
      if(SessionController().isLogin ?? false){
        Timer(Duration(seconds: 3), () =>
            Navigator.pushNamedAndRemoveUntil(context, RoutesName.eventDetailScreen, (route) => false));
      }else{
        Timer(Duration(seconds: 3), () =>
            Navigator.pushNamedAndRemoveUntil(context, RoutesName.loginScreen, (route) => false));
      }
    }).onError((error, stacktrace){
      Timer(Duration(seconds: 3), () =>
          Navigator.pushNamedAndRemoveUntil(context, RoutesName.loginScreen, (route) => false));
    });


  }
}