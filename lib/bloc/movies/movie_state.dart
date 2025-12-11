part of 'movie_bloc.dart';

class MovieState extends Equatable{

  ApiResponse<MoviesModel> movieModel;

  MovieState({
    required this.movieModel
});

  MovieState copyWith({
    ApiResponse<MoviesModel>? movieModel
  }){
    return MovieState(movieModel: movieModel ?? this.movieModel);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [];


}

