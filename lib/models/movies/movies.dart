
import 'package:freezed_annotation/freezed_annotation.dart';

part 'movies.freezed.dart';
part 'movies.g.dart';

@freezed
class MoviesModel with _$MoviesModel{

  factory MoviesModel({
    @Default(0) int total,
    @Default(0) int page,
    @Default(0) int pages,
    @Default([]) @JsonKey(name: 'tv_shows') List<TvShows> tvShow
  }) = _MoviesModel;

  factory MoviesModel.fromJson(Map<String, dynamic> json) => _$MoviesModelFromJson(json);

}

@freezed
class TvShows with _$TvShows{

  factory TvShows({
    @Default(0) int id,
    @Default('') String name,
    @Default('') @JsonKey(name: 'permalink') String permaLink,
    @Default('') @JsonKey(name: 'start_date') String startDate,
    @Default('') @JsonKey(name: 'end_date') String endDate,
    @Default('') @JsonKey(name: 'country') String country,
    @Default('') @JsonKey(name: 'network') String network,
    @Default('') @JsonKey(name: 'status') String status,
    @Default('') @JsonKey(name: 'image_thumbnail_path') String imageThumbnailPath,
  }) = _TvShows;

  factory TvShows.fromJson(Map<String, dynamic> json) => _$TvShowsFromJson(json);

}