import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gaanap_admin_new/models/user/user_model.dart';

import '../../config/routes/routes_name.dart';
import '../session_controller/session_controller.dart';

class SplashServices{

  void isLogin(BuildContext context){

    SessionController().getUserPreference().then((value){
      debugPrint("is Login ${SessionController().isLogin}");
      if(SessionController().isLogin ?? false){
        UserModel userModel= SessionController().userModel;
        String game_code = userModel.user?.gameCode ?? "";

        if(game_code.toLowerCase() == 'radio'){
          Navigator.pushNamedAndRemoveUntil(
            context,
            RoutesName.radioPlaylistScreen,
                (route) => false,
          );
        }else{
          Timer(Duration(seconds: 3), () =>
              Navigator.pushNamedAndRemoveUntil(context, RoutesName.eventDetailScreen, (route) => false));
        }

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