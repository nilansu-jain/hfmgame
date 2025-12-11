part of 'event_bloc.dart';

class EventState extends Equatable{

  EventStatus apiStatus;
  String message;

  EventState({
    this.apiStatus= EventStatus.initial,
    this.message=''
});

  EventState copyWith({
    EventStatus? apiStatus,
    String? message
}){
    return EventState(
      apiStatus: apiStatus ?? this.apiStatus,
      message: message ?? this.message
    );
}

  @override
  // TODO: implement props
  List<Object?> get props => [apiStatus,message];
}
