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

class GetGameDataEvent extends EventEvent{
  String game_id;
  String host_id;

  GetGameDataEvent({
    this.game_id ='',
    this.host_id ='',

  });

  @override
  // TODO: implement props
  List<Object> get props => [game_id,host_id];
}
class GetClipInfoEvent extends EventEvent{
  String clip_id;

  GetClipInfoEvent({
    this.clip_id ='',
  });

  @override
  // TODO: implement props
  List<Object> get props => [clip_id];
}
class SubmitClipAnswerEvent extends EventEvent{
  String game_id;
  String host_id;
  String user_id;
  String clip_id;
  String is_demo_clip;
  String answer_id;
  String score;
  String response_time;


  SubmitClipAnswerEvent({
    this.game_id ='',
    this.host_id ='',
    this.user_id ='',
    this.answer_id ='',
    this.clip_id ='',
    this.is_demo_clip ='',
    this.response_time ='',
    this.score ='',


  });

  @override
  // TODO: implement props
  List<Object> get props => [game_id,host_id,user_id,clip_id,is_demo_clip,answer_id,score,response_time];
}


