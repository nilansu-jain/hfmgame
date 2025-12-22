part of 'event_bloc.dart';

class EventState extends Equatable{

  EventStatus apiStatus;
  String message;
  EventStatus clipInfoStatus;
  GetClipInfoModel? clipInfoModel;


  EventState({
    this.apiStatus= EventStatus.initial,
    this.clipInfoStatus= EventStatus.initial,
    this.message='',
    this.clipInfoModel ,
});

  EventState copyWith({
    EventStatus? apiStatus,
    String? message,
    EventStatus? clipInfoStatus,
    GetClipInfoModel? clipInfoModel,

  }){
    return EventState(
      apiStatus: apiStatus ?? this.apiStatus,
      message: message ?? this.message,
      clipInfoStatus: clipInfoStatus ?? this.clipInfoStatus,
      clipInfoModel: clipInfoModel ?? clipInfoModel

    );
}

  @override
  // TODO: implement props
  List<Object?> get props => [apiStatus,message,clipInfoStatus,clipInfoModel];
}
