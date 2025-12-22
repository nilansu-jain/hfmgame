

import 'dart:io';

import '../../models/user/user_model.dart';

abstract class LoginRepository{

  @override
  Future<UserModel> loginApi( String username,
       String gameCode,
       String email,
      File? profilePhoto) ;

}