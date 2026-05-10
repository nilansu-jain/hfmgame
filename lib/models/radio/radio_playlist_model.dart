class RadioPlaylistResponseModel {
  final String? status;
  final String? message;
  final int? statusCode;
  final List<RadioPlaylistModel> playlists;

  const RadioPlaylistResponseModel({
    this.status,
    this.message,
    this.statusCode,
    this.playlists = const [],
  });

  factory RadioPlaylistResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = _extractPlaylistList(json);

    return RadioPlaylistResponseModel(
      status: json["status"]?.toString(),
      message: json["message"]?.toString(),
      statusCode: json["status_code"] is int
          ? json["status_code"] as int
          : int.tryParse(json["status_code"]?.toString() ?? ""),
      playlists: rawList
          .whereType<Map>()
          .map((item) => RadioPlaylistModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
    );
  }

  static List<dynamic> _extractPlaylistList(Map<String, dynamic> json) {
    final candidates = [
      json["playlists"],
      json["playlist"],
      json["data"],
      json["result"],
      if (json["data"] is Map) json["data"]["playlists"],
      if (json["data"] is Map) json["data"]["playlist"],
      if (json["data"] is Map) json["data"]["data"],
      if (json["result"] is Map) json["result"]["playlists"],
      if (json["result"] is Map) json["result"]["data"],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate;
      }
    }

    return const [];
  }
}

class RadioPlaylistModel {
  final int? id;
  final String title;
  final String songCount;
  final String? imageUrl;
  final String? updatedAt;

  const RadioPlaylistModel({
    this.id,
    required this.title,
    required this.songCount,
    this.imageUrl,
    this.updatedAt,
  });

  factory RadioPlaylistModel.fromJson(Map<String, dynamic> json) {
    final title = _firstString(json, [
      "title",
      "name",
      "playlist_name",
      "radio_playlist_name",
      "category_name",
    ]);
    final songCount = _firstString(json, [
      "song_count",
      "songs_count",
      "total_songs",
      "no_of_songs",
      "noOfSongs",
      "count",
    ]);

    return RadioPlaylistModel(
      id: _firstInt(json, ["id", "playlist_id", "radio_playlist_id"]),
      title: title.isEmpty ? "Untitled Playlist" : title,
      songCount: _songCountLabel(songCount),
      imageUrl: _firstString(json, [
        "image",
        "image_url",
        "thumbnail",
        "thumbnail_url",
        "cover",
        "cover_image",
        "playlist_image",
      ]),
      updatedAt: _firstString(json, [
        "updated_at",
        "updatedAt",
        "last_updated",
        "created_at",
      ]),
    );
  }

  static String _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return "";
  }

  static int? _firstInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      final parsed = int.tryParse(value?.toString() ?? "");
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  static String _songCountLabel(String value) {
    if (value.isEmpty) {
      return "0 Songs";
    }
    if (value.toLowerCase().contains("song")) {
      return value;
    }
    return "$value Songs";
  }
}

class RadioPlaylistSongsResponseModel {
  final String? status;
  final String? message;
  final int? statusCode;
  final List<RadioSongModel> songs;

  const RadioPlaylistSongsResponseModel({
    this.status,
    this.message,
    this.statusCode,
    this.songs = const [],
  });

  factory RadioPlaylistSongsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = _extractSongList(json);

    return RadioPlaylistSongsResponseModel(
      status: json["status"]?.toString(),
      message: json["message"]?.toString(),
      statusCode: json["status_code"] is int
          ? json["status_code"] as int
          : int.tryParse(json["status_code"]?.toString() ?? ""),
      songs: rawList
          .whereType<Map>()
          .map((item) =>
              RadioSongModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  static List<dynamic> _extractSongList(Map<String, dynamic> json) {
    final candidates = [
      json["songs"],
      json["song"],
      json["playlist_songs"],
      json["data"],
      json["result"],
      if (json["data"] is Map) json["data"]["songs"],
      if (json["data"] is Map) json["data"]["playlist_songs"],
      if (json["data"] is Map) json["data"]["data"],
      if (json["result"] is Map) json["result"]["songs"],
      if (json["result"] is Map) json["result"]["data"],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate;
      }
    }

    return const [];
  }
}

class RadioSongModel {
  final int? id;
  final String title;
  final String artist;
  final String durationLabel;
  final String? imageUrl;
  final String? audioUrl;
  final String lyricist;
  final String composer;
  final String movie;
  final String year;

  const RadioSongModel({
    this.id,
    required this.title,
    required this.artist,
    required this.durationLabel,
    this.imageUrl,
    this.audioUrl,
    required this.lyricist,
    required this.composer,
    required this.movie,
    required this.year,
  });

  factory RadioSongModel.fromJson(Map<String, dynamic> json) {
    final title = _firstString(json, [
      "song",
      "title",
      "song_title",
      "song_name",
      "name",
      "track",
    ]);
    final artist = _firstString(json, [
      "artist",
      "artist_name",
      "singer",
      "singers",
      "singer_name",
    ]);

    return RadioSongModel(
      id: _firstInt(json, ["id", "song_id", "playlist_song_id"]),
      title: title.isEmpty ? "Untitled Song" : title,
      artist: artist,
      durationLabel: _durationLabel(_firstString(json, [
        "song_full_length"
      ])),
      imageUrl: _firstString(json, [
        "image",
        "image_url",
        "thumbnail",
        "thumbnail_url",
        "cover",
        "cover_image",
        "song_image",
      ]),
      audioUrl: _firstString(json, [
        "audio",
        "audio_url",
        "song_path",
        "song_url",
        "mp3",
        "file",
        "file_url",
      ]),
      lyricist: _firstString(json, ["lyricist", "lyrics_by"]),
      composer: _firstString(json, ["composer", "music_by", "music"]),
      movie: _firstString(json, ["movie_name", "movie", "film", "album"]),
      year: _firstString(json, ["year", "release_year"]),
    );
  }

  static String _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return "";
  }

  static int? _firstInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      final parsed = int.tryParse(value?.toString() ?? "");
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  static String _durationLabel(String value) {
    if (value.isEmpty) {
      return "";
    }
    final seconds = int.tryParse(value);
    if (seconds == null) {
      return value;
    }
    final minutes = seconds ~/ 60;
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$remainingSeconds";
  }
}
