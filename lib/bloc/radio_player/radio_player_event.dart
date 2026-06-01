part of 'radio_player_bloc.dart';

abstract class RadioPlayerEvent extends Equatable {
  const RadioPlayerEvent();

  @override
  List<Object> get props => [];
}

class RadioStarted extends RadioPlayerEvent {}

class RadioPlaylistSearchChanged extends RadioPlayerEvent {
  final String searchQuery;

  const RadioPlaylistSearchChanged(this.searchQuery);

  @override
  List<Object> get props => [searchQuery];
}

class RadioPlaylistSongSearchVisibilityChanged extends RadioPlayerEvent {
  final bool isVisible;

  const RadioPlaylistSongSearchVisibilityChanged(this.isVisible);

  @override
  List<Object> get props => [isVisible];
}

class RadioPlaylistSongSearchChanged extends RadioPlayerEvent {
  final String searchQuery;

  const RadioPlaylistSongSearchChanged(this.searchQuery);

  @override
  List<Object> get props => [searchQuery];
}

class RadioPlaylistSearchByChanged extends RadioPlayerEvent {
  final String searchBy;

  const RadioPlaylistSearchByChanged(this.searchBy);

  @override
  List<Object> get props => [searchBy];
}

class RadioPlaylistSongSearchRequested extends RadioPlayerEvent {
  final String searchQuery;
  final String searchBy;

  const RadioPlaylistSongSearchRequested({
    required this.searchQuery,
    required this.searchBy,
  });

  @override
  List<Object> get props => [searchQuery, searchBy];
}

class RadioSearchSongSelected extends RadioPlayerEvent {
  final int songIndex;

  const RadioSearchSongSelected(this.songIndex);

  @override
  List<Object> get props => [songIndex];
}

class RadioSongAddToQueueRequested extends RadioPlayerEvent {
  final RadioSong song;

  const RadioSongAddToQueueRequested(this.song);

  @override
  List<Object> get props => [song];
}

class RadioPlaylistSelected extends RadioPlayerEvent {
  final int playlistIndex;

  const RadioPlaylistSelected(this.playlistIndex);

  @override
  List<Object> get props => [playlistIndex];
}

class RadioSongSearchChanged extends RadioPlayerEvent {
  final String searchQuery;

  const RadioSongSearchChanged(this.searchQuery);

  @override
  List<Object> get props => [searchQuery];
}

class RadioSongSelected extends RadioPlayerEvent {
  final int songIndex;

  const RadioSongSelected(this.songIndex);

  @override
  List<Object> get props => [songIndex];
}

class RadioShuffleRequested extends RadioPlayerEvent {}

class RadioPlayPauseRequested extends RadioPlayerEvent {}

class RadioNextRequested extends RadioPlayerEvent {}

class RadioPreviousRequested extends RadioPlayerEvent {}

class RadioSeekRequested extends RadioPlayerEvent {
  final Duration position;

  const RadioSeekRequested(this.position);

  @override
  List<Object> get props => [position];
}

class _RadioPlaybackChanged extends RadioPlayerEvent {
  final bool isPlaying;

  const _RadioPlaybackChanged(this.isPlaying);

  @override
  List<Object> get props => [isPlaying];
}

class _RadioDurationChanged extends RadioPlayerEvent {
  final Duration duration;

  const _RadioDurationChanged(this.duration);

  @override
  List<Object> get props => [duration];
}

class _RadioPositionChanged extends RadioPlayerEvent {
  final Duration position;

  const _RadioPositionChanged(this.position);

  @override
  List<Object> get props => [position];
}

class _RadioSongCompleted extends RadioPlayerEvent {}
