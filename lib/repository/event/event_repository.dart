

import 'package:gaanap_admin_new/models/get_clip_info_model.dart';
import 'package:gaanap_admin_new/models/get_game_data_model.dart';

import '../../models/user/user_model.dart';

abstract class EventRepository{

  @override
  Future<UserModel> joinEvent(data) ;

  Future<GetGameDataModel>  getGameData(data);
  Future<GetClipInfoModel>  GetClipInfo(data);
  Future<GetGameDataModel>  SubmitClipAnswer(data);


}