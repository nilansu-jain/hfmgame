
import 'dart:io';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import '../../repository/auth/login_repository.dart';
import '../../services/session_controller/session_controller.dart';
import '../../utils/enums.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  LoginRepository loginRepository ;

  LoginBloc({required this.loginRepository}) : super(LoginState()) {
    on<EmailChange>(_EmailChange);
    on<GameCodeChange>(_GameCodeChange);
    on<UsernameChange>(_UsernameChange);

    on<SubmitButton>(_submit);
    on<PasswordVisible>(_visibillity);
  }

  void _EmailChange(EmailChange event , Emitter<LoginState> emit){
    emit(
      state.copyWith(email: event.email,loginApiStatus: LoginApiStatus.initial)
    );
  }
  void _UsernameChange(UsernameChange event , Emitter<LoginState> emit){
    print("Event ${event.username}");
    emit(
        state.copyWith(username: event.username,loginApiStatus: LoginApiStatus.initial)
    );
  }
  void _GameCodeChange(GameCodeChange event , Emitter<LoginState> emit){
    emit(
        state.copyWith(gameCode: event.gameCode,loginApiStatus: LoginApiStatus.initial)
    );
  }



  void _submit(SubmitButton event, Emitter<LoginState> emit) async{
    emit(state.copyWith(loginApiStatus: LoginApiStatus.loading,message:"Loadinggg"));
    Map data ={
      "user_name":state.username,
      "game_code":state.gameCode,
      "email":state.email,
      "profile_photo":state.image
    };
    await loginRepository.loginApi( state.username,state.gameCode,state.email,state.image).then((value) async{
      if(value.status?.contains('error') ?? false){
        emit(state.copyWith(loginApiStatus: LoginApiStatus.error, message: value.message));

      }else{

        await SessionController().saveUserPreference(value);
        await SessionController().getUserPreference();

        emit(state.copyWith(loginApiStatus: LoginApiStatus.success, message: value.message));

      }
    }).onError((error,stacktrace){

      emit(state.copyWith(loginApiStatus: LoginApiStatus.error, message: error.toString()));
    });
  }

  void _visibillity(PasswordVisible event, Emitter<LoginState> emit){
    emit(
      state.copyWith(visible: event.visible,loginApiStatus: LoginApiStatus.initial)
    );
  }
}
