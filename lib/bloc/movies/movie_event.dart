part of 'movie_bloc.dart';


abstract class MovieEvent extends Equatable {

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class MoviesFetch extends MovieEvent{}
