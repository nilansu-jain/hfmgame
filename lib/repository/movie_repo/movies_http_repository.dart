
import '../../config/app_url.dart';
import '../../data/network/networkApiServices.dart';
import '../../models/movies/movies.dart';
import 'movies_repository.dart';

class MoviesHttpRepository extends MoviesRepository{

  final _api = Networkapiservices();

  @override
  Future<MoviesModel> fetchmovies() async{
    var response = await _api.getApi(AppUrl.moviesFetchApi);
    return MoviesModel.fromJson(response);
  }
}