import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../data/response/api_response.dart';
import '../../models/movies/movies.dart';
import '../../repository/movie_repo/movies_repository.dart';

part 'movie_event.dart';
part 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  
  MoviesRepository moviesRepository;
  
  MovieBloc({required this.moviesRepository}) : super(MovieState(movieModel: ApiResponse.loading())) {
    on<MoviesFetch>(_moviesFetch);
  }

  void _moviesFetch(MoviesFetch event, Emitter<MovieState> emit) async{
    await moviesRepository.fetchmovies().then((value){
      emit(state.copyWith(movieModel: ApiResponse.completed(value)));
    }).onError((error,stacktrace){
      emit(state.copyWith(movieModel: ApiResponse.error(error.toString())));

    });
  }

}
