import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gaanap_admin_new/models/get_clip_info_model.dart';
import 'package:gaanap_admin_new/models/get_game_data_model.dart';
import 'package:gaanap_admin_new/services/storage/local_storage.dart';
import 'package:gaanap_admin_new/utils/enums.dart';

import '../../repository/event/event_repository.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  EventRepository eventRepository;
  EventBloc({required this.eventRepository}) : super(EventState()) {
    on<JoinEvent>(_joinEvent);
    on<GetGameDataEvent>(_getGameData);
    on<GetClipInfoEvent>(_getClipInfo);
    on<SubmitClipAnswerEvent>(_submitClipAnswer);


  }

  void _joinEvent(JoinEvent event , Emitter<EventState> emit) async{
    emit(state.copyWith(apiStatus: EventStatus.loading,message:"Loadinggg"));
    Map data ={
      "game_id":event.game_id,
      "user_id":event.user_id,
      "host_id":event.host_id
    };
    await eventRepository.joinEvent( data).then((value) async{
      if(value.status?.contains('error') ?? false){
        emit(state.copyWith(apiStatus: EventStatus.error, message: value.message));

      }else{
        LocalStorage localStorage = LocalStorage();
        await localStorage.addData("game_status", "joined");

        emit(state.copyWith(apiStatus: EventStatus.completed, message: value.message));

      }
    }).onError((error,stacktrace){

      emit(state.copyWith(apiStatus: EventStatus.error, message: error.toString()));
    });
  }

  void _getGameData(GetGameDataEvent event , Emitter<EventState> emit) async{
    // emit(state.copyWith(apiStatus: EventStatus.loading,message:""));
    Map data ={
      "game_id":event.game_id,
      "host_id":event.host_id
    };
    await eventRepository.getGameData( data).then((value) async{
        await LocalStorage.saveModel("get_game_data", value);
        // emit(state.copyWith(apiStatus: EventStatus.completed));

    }).onError((error,stacktrace){

      // emit(state.copyWith(apiStatus: EventStatus.error, message: error.toString()));
    });
  }
  void _getClipInfo(GetClipInfoEvent event , Emitter<EventState> emit) async{
    emit(state.copyWith(apiStatus: EventStatus.loading,message:""));
    Map data ={
      "clip_id":event.clip_id,
    };
    await eventRepository.GetClipInfo( data).then((value) async{
      emit(state.copyWith(clipInfoStatus: EventStatus.completed, clipInfoModel: value));

    }).onError((error,stacktrace){

      emit(state.copyWith(clipInfoStatus: EventStatus.error, message: error.toString()));
    });
  }
  void _submitClipAnswer(SubmitClipAnswerEvent event , Emitter<EventState> emit) async{
    emit(state.copyWith(apiStatus: EventStatus.loading,message:"Loadinggg"));
    Map data ={
      "game_id":event.game_id,
      "user_id":event.user_id,
      "host_id":event.host_id,
      "clip_id":event.clip_id,
      "is_demo_clip":event.is_demo_clip,
      "answer_id":event.answer_id,
      "score":event.score,
      "response_time":event.response_time,

    };
    await eventRepository.SubmitClipAnswer( data).then((value) async{

        emit(state.copyWith(apiStatus: EventStatus.completed, message:""));


    }).onError((error,stacktrace){

      emit(state.copyWith(apiStatus: EventStatus.error, message: error.toString()));
    });
  }

}
