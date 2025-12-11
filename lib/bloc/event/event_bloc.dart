import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gaanap_admin_new/utils/enums.dart';

import '../../repository/event/event_repository.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  EventRepository eventRepository;
  EventBloc({required this.eventRepository}) : super(EventState()) {
    on<JoinEvent>(_joinEvent);

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

        emit(state.copyWith(apiStatus: EventStatus.completed, message: value.message));

      }
    }).onError((error,stacktrace){

      emit(state.copyWith(apiStatus: EventStatus.error, message: error.toString()));
    });
  }
}
