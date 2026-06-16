part of 'radio_player_bloc.dart';

enum RadioPlaylistStatus { initial, loading, completed, error }

enum RadioSongsStatus { initial, loading, completed, error }

class RadioPlaylist extends Equatable {
  final int? id;
  final String title;
  final String songCount;
  final String imageAsset;
  final String? imageUrl;
  final String updatedAt;

  const RadioPlaylist({
    this.id,
    required this.title,
    required this.songCount,
    required this.imageAsset,
    this.imageUrl,
    required this.updatedAt,
  });

  factory RadioPlaylist.fromModel(RadioPlaylistModel model) {
    return RadioPlaylist(
      id: model.id,
      title: model.title,
      songCount: model.songCount,
      imageAsset: 'assets/images/radio_playlist_cover.png',
      imageUrl: model.imageUrl,
      updatedAt: (model.updatedAt?.isNotEmpty ?? false)
          ? 'Updated ${model.updatedAt}'
          : '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        songCount,
        imageAsset,
        imageUrl,
        updatedAt,
      ];
}

class RadioSong extends Equatable {
  final int? id;
  final String title;
  final String artist;
  final String durationLabel;
  final String imageAsset;
  final String? imageUrl;
  final String audioAsset;
  final String? audioUrl;
  final String lyricist;
  final String composer;
  final String movie;
  final String year;

  const RadioSong({
    this.id,
    required this.title,
    required this.artist,
    required this.durationLabel,
    required this.imageAsset,
    this.imageUrl,
    required this.audioAsset,
    this.audioUrl,
    required this.lyricist,
    required this.composer,
    required this.movie,
    required this.year,
  });

  factory RadioSong.fromModel(RadioSongModel model) {
    return RadioSong(
      id: model.id,
      title: model.title,
      artist: model.artist.isEmpty ? 'Unknown Artist' : model.artist,
      durationLabel: model.durationLabel,
      imageAsset: 'assets/images/radio_shola_cover.png',
      imageUrl: model.imageUrl,
      audioAsset: 'assets/audio/song.mp3',
      audioUrl: model.audioUrl,
      lyricist: model.lyricist,
      composer: model.composer,
      movie: model.movie,
      year: model.year,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        durationLabel,
        imageAsset,
        imageUrl,
        audioAsset,
        audioUrl,
        lyricist,
        composer,
        movie,
        year,
      ];
}

class RadioPlayerState extends Equatable {
  final List<RadioPlaylist> playlists;
  final List<RadioSong> songs;
  final List<RadioSong> searchSongs;
  final int selectedPlaylistIndex;
  final int selectedSongIndex;
  final bool isPlaying;
  final bool hasSelectedSong;
  final Set<int> playedSongIndexes;
  final Duration duration;
  final Duration position;
  final RadioPlaylistStatus playlistStatus;
  final String playlistMessage;
  final String playlistSearchQuery;
  final String searchQuery;
  final String playlistSearchBy;
  final bool isPlaylistSongSearchVisible;
  final RadioSongsStatus searchSongsStatus;
  final String searchSongsMessage;
  final RadioSongsStatus songsStatus;
  final String songsMessage;
  final String songSearchQuery;
  final bool isSearchPlayback;
  final int playingSearchSongId;
  final int playingPlaylistId;
  final List<RadioSong> queueBeforeSearch;
  final RadioSong? playingSong;

  const RadioPlayerState({
    required this.playlists,
    required this.songs,
    required this.searchSongs,
    required this.selectedPlaylistIndex,
    required this.selectedSongIndex,
    required this.isPlaying,
    required this.hasSelectedSong,
    required this.playedSongIndexes,
    required this.duration,
    required this.position,
    required this.playlistStatus,
    required this.playlistMessage,
    required this.playlistSearchQuery,
    required this.searchQuery,
    required this.playlistSearchBy,
    required this.isPlaylistSongSearchVisible,
    required this.searchSongsStatus,
    required this.searchSongsMessage,
    required this.songsStatus,
    required this.songsMessage,
    required this.songSearchQuery,
    required this.isSearchPlayback,
    required this.playingSearchSongId,
    required this.playingPlaylistId,
    required this.queueBeforeSearch,
    required this.playingSong,
  });

  factory RadioPlayerState.initial() {
    return const RadioPlayerState(
      playlists: [],
      songs: [],
      searchSongs: [],
      selectedPlaylistIndex: 0,
      selectedSongIndex: 0,
      isPlaying: false,
      hasSelectedSong: false,
      playedSongIndexes: {},
      duration: Duration.zero,
      position: Duration.zero,
      playlistStatus: RadioPlaylistStatus.initial,
      playlistMessage: '',
      playlistSearchQuery: '',
      searchQuery: '',
      playlistSearchBy: 'song',
      isPlaylistSongSearchVisible: false,
      searchSongsStatus: RadioSongsStatus.initial,
      searchSongsMessage: '',
      songsStatus: RadioSongsStatus.initial,
      songsMessage: '',
      songSearchQuery: '',
      isSearchPlayback: false,
      playingSearchSongId: 0,
      playingPlaylistId: -1,
      queueBeforeSearch: const [],
      playingSong: null
    );
  }

  RadioPlaylist get currentPlaylist {
    if (playlists.isEmpty) {
      return const RadioPlaylist(
        title: '1 Star HFM',
        songCount: '0 Songs',
        imageAsset: 'assets/images/radio_playlist_cover.png',
        updatedAt: '',
      );
    }
    if (selectedPlaylistIndex >= playlists.length) {
      return playlists.first;
    }
    return playlists[selectedPlaylistIndex];
  }

  RadioSong get currentSong {
    if (!hasSelectedSong || songs.isEmpty) {
      return const RadioSong(
        title: '',
        artist: '',
        durationLabel: '',
        imageAsset: 'assets/images/radio_shola_cover.png',
        audioAsset: 'assets/audio/song.mp3',
        lyricist: '',
        composer: '',
        movie: '',
        year: '',
      );
    }
    if (selectedSongIndex >= songs.length) {
      return songs.first;
    }
    return songs[selectedSongIndex];
  }

  List<RadioPlaylist> get filteredPlaylists {
    final query = playlistSearchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return playlists;
    }

    return playlists.where((playlist) {
      return playlist.title.toLowerCase().contains(query) ||
          playlist.songCount.toLowerCase().contains(query);
    }).toList();
  }

  List<RadioSong> get filteredSongs {
    final query = songSearchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return songs;
    }

    return songs.where((song) {
      return song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query) ||
          song.movie.toLowerCase().contains(query);
    }).toList();
  }

  RadioPlayerState copyWith({
    List<RadioPlaylist>? playlists,
    List<RadioSong>? songs,
    List<RadioSong>? searchSongs,
    int? selectedPlaylistIndex,
    int? selectedSongIndex,
    bool? isPlaying,
    bool? hasSelectedSong,
    Set<int>? playedSongIndexes,
    Duration? duration,
    Duration? position,
    RadioPlaylistStatus? playlistStatus,
    String? playlistMessage,
    String? playlistSearchQuery,
    String? searchQuery,
    String? playlistSearchBy,
    bool? isPlaylistSongSearchVisible,
    RadioSongsStatus? searchSongsStatus,
    String? searchSongsMessage,
    RadioSongsStatus? songsStatus,
    String? songsMessage,
    String? songSearchQuery,
    bool? isSearchPlayback,
    int? playingSearchSongId,
    int? playingPlaylistId,
    List<RadioSong>? queueBeforeSearch,
    RadioSong? playingSong,
  }) {
    return RadioPlayerState(
      playlists: playlists ?? this.playlists,
      songs: songs ?? this.songs,
      searchSongs: searchSongs ?? this.searchSongs,
      selectedPlaylistIndex:
          selectedPlaylistIndex ?? this.selectedPlaylistIndex,
      selectedSongIndex: selectedSongIndex ?? this.selectedSongIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      hasSelectedSong: hasSelectedSong ?? this.hasSelectedSong,
      playedSongIndexes: playedSongIndexes ?? this.playedSongIndexes,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      playlistStatus: playlistStatus ?? this.playlistStatus,
      playlistMessage: playlistMessage ?? this.playlistMessage,
      playlistSearchQuery: playlistSearchQuery ?? this.playlistSearchQuery,
      searchQuery: searchQuery ?? this.searchQuery,
      playlistSearchBy: playlistSearchBy ?? this.playlistSearchBy,
      isPlaylistSongSearchVisible:
          isPlaylistSongSearchVisible ?? this.isPlaylistSongSearchVisible,
      searchSongsStatus: searchSongsStatus ?? this.searchSongsStatus,
      searchSongsMessage: searchSongsMessage ?? this.searchSongsMessage,
      songsStatus: songsStatus ?? this.songsStatus,
      songsMessage: songsMessage ?? this.songsMessage,
      songSearchQuery: songSearchQuery ?? this.songSearchQuery,
      playingSearchSongId: playingSearchSongId ?? this.playingSearchSongId,
      isSearchPlayback: isSearchPlayback ?? this.isSearchPlayback,
      playingPlaylistId:
      playingPlaylistId ?? this.playingPlaylistId,
      queueBeforeSearch: queueBeforeSearch ?? this.queueBeforeSearch,
      playingSong: playingSong ?? this.playingSong
    );
  }

  @override
  List<Object?> get props => [
        playlists,
        songs,
        searchSongs,
        selectedPlaylistIndex,
        selectedSongIndex,
        isPlaying,
        hasSelectedSong,
        playedSongIndexes,
        duration,
        position,
        playlistStatus,
        playlistMessage,
        playlistSearchQuery,
        searchQuery,
        playlistSearchBy,
        isPlaylistSongSearchVisible,
        searchSongsStatus,
        searchSongsMessage,
        songsStatus,
        songsMessage,
        songSearchQuery,
        isSearchPlayback,
        playingSearchSongId,
    playingPlaylistId,
    queueBeforeSearch,
    playingSong
      ];
}
