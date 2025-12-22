

import 'package:flutter/foundation.dart';
import 'package:gaanap_admin_new/models/get_clip_info_model.dart';
import 'package:gaanap_admin_new/models/get_game_data_model.dart';
import 'package:gaanap_admin_new/repository/event/event_repository.dart';

import '../../config/app_url.dart';
import '../../data/network/networkApiServices.dart';
import '../../models/user/user_model.dart';
import '../../services/session_controller/session_controller.dart';

class EventHttpRepository implements EventRepository{

  final _api = Networkapiservices();

  @override
  Future<UserModel> joinEvent(data) async{
    UserModel userModel= SessionController().userModel;

    var token  = userModel.authToken;
    Map<String,String> header = {"auth-api-key": token ?? ""};
    var response = await _api.postApi(AppUrl.joinEventUrl, data,header: header);
    debugPrint("Data : ${UserModel.fromJson(response)}");
    return UserModel.fromJson(response);
  }

  @override
  Future<GetGameDataModel> getGameData(data) async{
    UserModel userModel= SessionController().userModel;

    var token  = userModel.authToken;
    Map<String,String> header = {"auth-api-key": token ?? ""};
    var response = await _api.postApi(AppUrl.getGameData, data,header: header);
    debugPrint("Data : ${GetGameDataModel.fromJson(response)}");
    return GetGameDataModel.fromJson(response);
  }

  @override
  Future<GetClipInfoModel> GetClipInfo(data) async{
    UserModel userModel= SessionController().userModel;

    var token  = userModel.authToken;
    Map<String,String> header = {"auth-api-key": token ?? ""};
    var response = await _api.postApi(AppUrl.getClipInfo, data,header: header);
    debugPrint("Data : ${GetClipInfoModel.fromJson(response)}");
    return GetClipInfoModel.fromJson(response);
  }

  @override
  Future<GetGameDataModel> SubmitClipAnswer(data) async{
    UserModel userModel= SessionController().userModel;

    var token  = userModel.authToken;
    Map<String,String> header = {"auth-api-key": token ?? ""};
    var response = await _api.postApi(AppUrl.submitClipAnswer, data,header: header);
    debugPrint("Data : ${GetGameDataModel.fromJson(response)}");
    return GetGameDataModel.fromJson(response);
  }

}