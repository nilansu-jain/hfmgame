part of 'event_bloc.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object> get props => [];
}

class JoinEvent extends EventEvent{
  String game_id;
  String user_id;
  String host_id;

  JoinEvent({
    this.game_id ='',
    this.user_id ='',
    this.host_id ='',

  });

  @override
  // TODO: implement props
  List<Object> get props => [game_id,user_id,host_id];
}

