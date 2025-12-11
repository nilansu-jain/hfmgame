

import '../../models/user/user_model.dart';
import 'login_repository.dart';

class LoginMockRepository implements LoginRepository{


  Future<UserModel> loginApi(data) async{
    await Duration(seconds: 3);
    var response ={
      'token': 'fhjdnfgdjfg'
    };
    return UserModel.fromJson(response);
  }

}