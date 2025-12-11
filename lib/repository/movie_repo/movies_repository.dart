import '../../models/movies/movies.dart';

abstract  class MoviesRepository{

  Future<MoviesModel> fetchmovies();
}