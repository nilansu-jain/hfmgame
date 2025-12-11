part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable{

  const LoginEvent();

  @override
List<Object> get props => [];

}

class EmailChange extends LoginEvent{
  String email;

  EmailChange({
    this.email =''
});

  @override
  // TODO: implement props
  List<Object> get props => [email];
}

class UsernameChange extends LoginEvent{
  String username;

  UsernameChange({
    this.username =''
  });

  @override
  // TODO: implement props
  List<Object> get props => [username];
}

class GameCodeChange extends LoginEvent{
  String gameCode;

  GameCodeChange({
    this.gameCode =''
  });

  @override
  // TODO: implement props
  List<Object> get props => [gameCode];
}

class SubmitButton extends LoginEvent{

}

class PasswordVisible extends LoginEvent{
  bool visible;

  PasswordVisible({
    this.visible= false
});

  @override
  // TODO: implement props
  List<Object> get props => [visible];
}
