part of 'login_bloc.dart';

 class LoginState extends Equatable{

   String username;
   String gameCode;
   String email;
   File? image;

   String message;
   bool visible;
   LoginApiStatus loginApiStatus;

   LoginState({
     this.email = '',
     this.username ='',
     this.gameCode='',
     this.message ='',
     this.visible = false,
     this.loginApiStatus = LoginApiStatus.initial,
     this.image
 });

   LoginState copyWith({
     String? email,
     String? username,
     String? gameCode,
     String? message,
     bool? visible,
     LoginApiStatus? loginApiStatus,
     File? image

   }){
     return LoginState(
       email: email ?? this.email,
         username: username ?? this.username,
         gameCode: gameCode ?? this.gameCode,
       message: message ?? this.message,
       visible: visible ?? this.visible,
       loginApiStatus: loginApiStatus ?? this.loginApiStatus,
       image: image ?? this.image
     );
   }

  @override
  // TODO: implement props
  List<Object?> get props => [email,gameCode,visible,loginApiStatus,message,username,image];

 }


