

import '../../models/user/user_model.dart';

abstract class EventRepository{

  @override
  Future<UserModel> joinEvent(data) ;

}