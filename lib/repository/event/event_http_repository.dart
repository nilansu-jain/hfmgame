

import 'package:flutter/foundation.dart';
import 'package:gaanap_admin_new/repository/event/event_repository.dart';

import '../../config/app_url.dart';
import '../../data/network/networkApiServices.dart';
import '../../models/user/user_model.dart';

class EventHttpRepository implements EventRepository{

  final _api = Networkapiservices();

  @override
  Future<UserModel> joinEvent(data) async{
    var response = await _api.postApi(AppUrl.joinEventUrl, data);
    debugPrint("Data : ${UserModel.fromJson(response)}");
    return UserModel.fromJson(response);
  }

}