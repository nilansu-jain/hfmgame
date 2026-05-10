import 'package:flutter/foundation.dart';
import 'package:gaanap_admin_new/config/app_url.dart';
import 'package:gaanap_admin_new/data/network/networkApiServices.dart';
import 'package:gaanap_admin_new/models/radio/radio_playlist_model.dart';
import 'package:gaanap_admin_new/models/user/user_model.dart';
import 'package:gaanap_admin_new/repository/radio/radio_repository.dart';
import 'package:gaanap_admin_new/services/session_controller/session_controller.dart';

class RadioHttpRepository implements RadioRepository {
  final _api = Networkapiservices();

  @override
  Future<RadioPlaylistResponseModel> getPlaylists({
    String searchKey = "",
  }) async {
    UserModel userModel = SessionController().userModel;
    final token = userModel.authToken;
    final header = {
      "auth-api-key":
          (token?.isNotEmpty ?? false) ? token! : AppUrl.radioDefaultAuthApiKey,
    };
    final response = await _api.postJsonApi(
      AppUrl.radioGetPlaylists,
      {"skey": searchKey},
      header: header,
    );
    final playlistResponse = RadioPlaylistResponseModel.fromJson(response);
    debugPrint("Radio playlists : ${playlistResponse.playlists.length}");
    return playlistResponse;
  }

  @override
  Future<RadioPlaylistSongsResponseModel> getPlaylistSongs({
    required int playlistId,
    String searchKey = "",
  }) async {
    UserModel userModel = SessionController().userModel;
    final token = userModel.authToken;
    final header = {
      "auth-api-key": (token?.isNotEmpty ?? false)
          ? token!
          : AppUrl.radioSongsDefaultAuthApiKey,
    };
    final response = await _api.postJsonApi(
      AppUrl.radioGetPlaylistSongs,
      {
        "playlist_id": playlistId,
        "skey": searchKey,
      },
      header: header,
    );
    final songsResponse = RadioPlaylistSongsResponseModel.fromJson(response);
    debugPrint("Radio playlist songs : ${songsResponse.songs.length}");
    return songsResponse;
  }

  @override
  Future<RadioPlaylistSongsResponseModel> searchSongs({
    required String searchKey,
    required String searchBy,
  }) async {
    UserModel userModel = SessionController().userModel;
    final token = userModel.authToken;
    final header = {
      "auth-api-key": (token?.isNotEmpty ?? false)
          ? token!
          : AppUrl.radioSongsDefaultAuthApiKey,
    };
    final response = await _api.postJsonApi(
      AppUrl.radioSearchSongs,
      {
        "skey": searchKey,
        "search_by": searchBy,
      },
      header: header,
    );
    final songsResponse = RadioPlaylistSongsResponseModel.fromJson(response);
    debugPrint("Radio search songs : ${songsResponse.songs.length}");
    return songsResponse;
  }
}
