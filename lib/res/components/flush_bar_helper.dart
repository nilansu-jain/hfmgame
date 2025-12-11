import 'package:another_flushbar/flushbar_route.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '../color/colors.dart';

class FlushBarHelper {

  static void flushBarErrorMessage(String message , BuildContext context){
    showFlushbar(context: context, flushbar: Flushbar(
      title: "Error",
      message: message,
      borderRadius: BorderRadius.circular(10),
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
      backgroundColor: AppColors.red,
      margin: EdgeInsets.all(10),
      duration: Duration(seconds: 3),
      titleColor: AppColors.white,
      messageColor: AppColors.white,
      flushbarPosition: FlushbarPosition.TOP,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      reverseAnimationCurve:Curves.bounceIn ,
      positionOffset: 10,
      icon: Icon(Icons.error,
      color: AppColors.white,),
      forwardAnimationCurve: Curves.bounceInOut,
      isDismissible: true,
    )..show(context));
  }
  static void flushBarSuccessMessage(String message , BuildContext context){
    showFlushbar(context: context, flushbar: Flushbar(
      title: "Success",
      message: message,
      borderRadius: BorderRadius.circular(10),
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
      backgroundColor: Colors.green,
      margin: EdgeInsets.all(10),
      duration: Duration(seconds: 3),
      titleColor: AppColors.white,
      messageColor: AppColors.white,
      flushbarPosition: FlushbarPosition.TOP,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      reverseAnimationCurve:Curves.bounceIn ,
      positionOffset: 10,
      icon: Icon(Icons.check_circle_outline,
      color: AppColors.white,),
      forwardAnimationCurve: Curves.bounceInOut,
      isDismissible: true,
    )..show(context));
  }
}