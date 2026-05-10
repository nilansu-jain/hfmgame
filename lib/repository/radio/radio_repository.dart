import 'package:gaanap_admin_new/models/radio/radio_playlist_model.dart';

abstract class RadioRepository {
  Future<RadioPlaylistResponseModel> getPlaylists({
    String searchKey = "",
  });

  Future<RadioPlaylistSongsResponseModel> getPlaylistSongs({
    required int playlistId,
    String searchKey = "",
  });

  Future<RadioPlaylistSongsResponseModel> searchSongs({
    required String searchKey,
    required String searchBy,
  });
}
