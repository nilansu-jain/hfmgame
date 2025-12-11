

import '../../models/user/user_model.dart';

abstract class LoginRepository{

  @override
  Future<UserModel> loginApi(data) ;

}