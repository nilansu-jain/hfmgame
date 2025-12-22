import 'dart:convert';

class GetClipInfoModel {
  String? status;
  Data? data;

  GetClipInfoModel({
    this.status,
    this.data,
  });

  GetClipInfoModel copyWith({
    String? status,
    Data? data,
  }) =>
      GetClipInfoModel(
        status: status ?? this.status,
        data: data ?? this.data,
      );

  factory GetClipInfoModel.fromRawJson(String str) => GetClipInfoModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetClipInfoModel.fromJson(Map<String, dynamic> json) => GetClipInfoModel(
    status: json["status"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
  };
}

class Data {
  String? song;
  String? thumbnail;
  String? movieName;
  String? singer;
  String? year;
  String? composer;
  String? lyricist;
  int? rating;
  String? didYouKnow;

  Data({
    this.song,
    this.thumbnail,
    this.movieName,
    this.singer,
    this.year,
    this.composer,
    this.lyricist,
    this.rating,
    this.didYouKnow,
  });

  Data copyWith({
    String? song,
    String? thumbnail,
    String? movieName,
    String? singer,
    String? year,
    String? composer,
    String? lyricist,
    int? rating,
    String? didYouKnow,
  }) =>
      Data(
        song: song ?? this.song,
        thumbnail: thumbnail ?? this.thumbnail,
        movieName: movieName ?? this.movieName,
        singer: singer ?? this.singer,
        year: year ?? this.year,
        composer: composer ?? this.composer,
        lyricist: lyricist ?? this.lyricist,
        rating: rating ?? this.rating,
        didYouKnow: didYouKnow ?? this.didYouKnow,
      );

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    song: json["song"],
    thumbnail: json["thumbnail"],
    movieName: json["movie_name"],
    singer: json["singer"],
    year: json["year"],
    composer: json["composer"],
    lyricist: json["lyricist"],
    rating: json["rating"],
    didYouKnow: json["did_you_know"],
  );

  Map<String, dynamic> toJson() => {
    "song": song,
    "thumbnail": thumbnail,
    "movie_name": movieName,
    "singer": singer,
    "year": year,
    "composer": composer,
    "lyricist": lyricist,
    "rating": rating,
    "did_you_know": didYouKnow,
  };
}
