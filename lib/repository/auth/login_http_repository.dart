

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/app_url.dart';
import '../../data/network/networkApiServices.dart';
import '../../models/user/user_model.dart';
import 'login_repository.dart';

class LoginHttpRepository implements LoginRepository{

  final _api = Networkapiservices();

  @override
  Future<UserModel> loginApi(  String username,
       String gameCode,
       String email,
      File? profilePhoto,) async{
    debugPrint("profile photo :: ${profilePhoto?.path}");
    final formData = FormData.fromMap({
      "user_name": username,
      "game_code": gameCode,
      "email": email,
      if (profilePhoto != null)
        "profile_photo": await MultipartFile.fromFile(
          profilePhoto.path,
          filename: profilePhoto.path.split('/').last,
        ),
    });
    debugPrint("Form Data :: ${formData}");
    var response = await _api.postMultipartApi(AppUrl.loginUrl, formData);
    debugPrint("Data : ${UserModel.fromJson(response)}");
    return UserModel.fromJson(response);
  }

}