

import 'package:flutter/foundation.dart';

import '../../config/app_url.dart';
import '../../data/network/networkApiServices.dart';
import '../../models/user/user_model.dart';
import 'login_repository.dart';

class LoginHttpRepository implements LoginRepository{

  final _api = Networkapiservices();

  @override
  Future<UserModel> loginApi(data) async{
    var response = await _api.postApi(AppUrl.loginUrl, data);
    debugPrint("Data : ${UserModel.fromJson(response)}");
    return UserModel.fromJson(response);
  }

}