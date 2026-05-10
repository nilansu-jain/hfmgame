import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gaanap_admin_new/models/radio/radio_playlist_model.dart';
import 'package:gaanap_admin_new/repository/radio/radio_repository.dart';
import 'package:just_audio/just_audio.dart';

part 'radio_player_event.dart';
part 'radio_player_state.dart';

class RadioPlayerBloc extends Bloc<RadioPlayerEvent, RadioPlayerState> {
  final RadioRepository radioRepository;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  Timer? _playlistSearchDebounce;
  int _playlistSearchRequestId = 0;

  RadioPlayerBloc({required this.radioRepository})
      : super(RadioPlayerState.initial()) {
    on<RadioStarted>(_onStarted);
    on<RadioPlaylistSearchChanged>(_onPlaylistSearchChanged);
    on<RadioPlaylistSongSearchVisibilityChanged>(
      _onPlaylistSongSearchVisibilityChanged,
    );
    on<RadioPlaylistSongSearchChanged>(_onPlaylistSongSearchChangedEvent);
    on<RadioPlaylistSearchByChanged>(_onPlaylistSearchByChanged);
    on<RadioPlaylistSongSearchRequested>(_onPlaylistSongSearchRequested);
    on<RadioPlaylistSelected>(_onPlaylistSelected);
    on<RadioSongSearchChanged>(_onSongSearchChanged);
    on<RadioSongSelected>(_onSongSelected);
    on<RadioSearchSongSelected>(_onSearchSongSelected);
    on<RadioShuffleRequested>(_onShuffleRequested);
    on<RadioPlayPauseRequested>(_onPlayPauseRequested);
    on<RadioNextRequested>(_onNextRequested);
    on<RadioPreviousRequested>(_onPreviousRequested);
    on<RadioSeekRequested>(_onSeekRequested);
    on<_RadioPlaybackChanged>(_onPlaybackChanged);
    on<_RadioDurationChanged>(_onDurationChanged);
    on<_RadioPositionChanged>(_onPositionChanged);
    on<_RadioSongCompleted>(_onSongCompleted);
  }

  Future<void> _onStarted(
    RadioStarted event,
    Emitter<RadioPlayerState> emit,
  ) async {
    _playerStateSubscription ??=
        _audioPlayer.playerStateStream.listen((playerState) {
      add(_RadioPlaybackChanged(playerState.playing));
      if (playerState.processingState == ProcessingState.completed) {
        add(_RadioSongCompleted());
      }
    });
    _durationSubscription ??= _audioPlayer.durationStream.listen((duration) {
      add(_RadioDurationChanged(duration ?? Duration.zero));
    });
    _positionSubscription ??= _audioPlayer.positionStream.listen((position) {
      add(_RadioPositionChanged(position));
    });
    emit(state.copyWith(playlistStatus: RadioPlaylistStatus.loading));
    try {
      final response = await radioRepository.getPlaylists();
      final hasErrorStatus = (response.statusCode ?? 200) >= 400 ||
          (response.status?.toLowerCase().contains('error') ?? false);
      if (hasErrorStatus) {
        emit(
          state.copyWith(
            playlistStatus: RadioPlaylistStatus.error,
            playlistMessage: response.message ?? 'Unable to load playlists',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          playlists: response.playlists
              .map((playlist) => RadioPlaylist.fromModel(playlist))
              .toList(),
          playlistStatus: RadioPlaylistStatus.completed,
          playlistMessage: response.message ?? "",
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          playlistStatus: RadioPlaylistStatus.error,
          playlistMessage: error.toString(),
        ),
      );
    }
  }

  void _onPlaylistSearchChanged(
    RadioPlaylistSearchChanged event,
    Emitter<RadioPlayerState> emit,
  ) {
    emit(state.copyWith(playlistSearchQuery: event.searchQuery));
  }

  void _onPlaylistSongSearchVisibilityChanged(
    RadioPlaylistSongSearchVisibilityChanged event,
    Emitter<RadioPlayerState> emit,
  ) {
    _playlistSearchDebounce?.cancel();
    _playlistSearchRequestId++;
    emit(
      state.copyWith(
        isPlaylistSongSearchVisible: event.isVisible,
        searchQuery: '',
        searchSongs: const [],
        searchSongsStatus: RadioSongsStatus.initial,
        searchSongsMessage: '',
      ),
    );
  }

  void _onPlaylistSongSearchChanged(
    String searchQuery,
    Emitter<RadioPlayerState> emit,
  ) {
    final query = searchQuery;
    _playlistSearchDebounce?.cancel();
    if (query.trim().isEmpty) {
      _playlistSearchRequestId++;
      emit(
        state.copyWith(
          isPlaylistSongSearchVisible: true,
          searchQuery: query,
          searchSongs: const [],
          searchSongsStatus: RadioSongsStatus.initial,
          searchSongsMessage: '',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isPlaylistSongSearchVisible: true,
        searchQuery: query,
        playlistSearchQuery: '',
        searchSongs: const [],
        searchSongsStatus: RadioSongsStatus.loading,
        searchSongsMessage: '',
      ),
    );
    _playlistSearchDebounce = Timer(const Duration(milliseconds: 500), () {
      add(
        RadioPlaylistSongSearchRequested(
          searchQuery: query,
          searchBy: state.playlistSearchBy,
        ),
      );
    });
  }

  void _onPlaylistSongSearchChangedEvent(
    RadioPlaylistSongSearchChanged event,
    Emitter<RadioPlayerState> emit,
  ) {
    _onPlaylistSongSearchChanged(event.searchQuery, emit);
  }

  void _onPlaylistSearchByChanged(
    RadioPlaylistSearchByChanged event,
    Emitter<RadioPlayerState> emit,
  ) {
    emit(state.copyWith(playlistSearchBy: event.searchBy));
    final query = state.searchQuery;
    if (query.trim().isNotEmpty) {
      _playlistSearchDebounce?.cancel();
      add(
        RadioPlaylistSongSearchRequested(
          searchQuery: query,
          searchBy: event.searchBy,
        ),
      );
    }
  }

  Future<void> _onPlaylistSongSearchRequested(
    RadioPlaylistSongSearchRequested event,
    Emitter<RadioPlayerState> emit,
  ) async {
    final query = event.searchQuery.trim();
    if (query.isEmpty) {
      emit(
        state.copyWith(
          searchSongs: const [],
          searchSongsStatus: RadioSongsStatus.initial,
          searchSongsMessage: '',
        ),
      );
      return;
    }

    final requestId = ++_playlistSearchRequestId;
    emit(
      state.copyWith(
        searchSongsStatus: RadioSongsStatus.loading,
        searchSongsMessage: '',
      ),
    );

    try {
      final response = await radioRepository.searchSongs(
        searchKey: query,
        searchBy: event.searchBy,
      );
      if (requestId != _playlistSearchRequestId) {
        return;
      }
      final hasErrorStatus = (response.statusCode ?? 200) >= 400 ||
          (response.status?.toLowerCase().contains('error') ?? false);
      if (hasErrorStatus) {
        emit(
          state.copyWith(
            searchSongsStatus: RadioSongsStatus.error,
            searchSongsMessage: response.message ?? 'Unable to search songs',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          searchSongs:
              response.songs.map((song) => RadioSong.fromModel(song)).toList(),
          searchSongsStatus: RadioSongsStatus.completed,
          searchSongsMessage: response.message ?? '',
        ),
      );
    } catch (error) {
      if (requestId != _playlistSearchRequestId) {
        return;
      }
      emit(
        state.copyWith(
          searchSongsStatus: RadioSongsStatus.error,
          searchSongsMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onPlaylistSelected(
    RadioPlaylistSelected event,
    Emitter<RadioPlayerState> emit,
  ) async {
    await _audioPlayer.stop();
    emit(
      state.copyWith(
        selectedPlaylistIndex: event.playlistIndex,
        songs: const [],
        selectedSongIndex: 0,
        isPlaying: false,
        hasSelectedSong: false,
        playedSongIndexes: {},
        duration: Duration.zero,
        position: Duration.zero,
        songsStatus: RadioSongsStatus.loading,
        songsMessage: '',
        songSearchQuery: '',
      ),
    );

    final playlistId = state.currentPlaylist.id;
    if (playlistId == null) {
      emit(
        state.copyWith(
          songsStatus: RadioSongsStatus.error,
          songsMessage: 'Playlist id not found',
        ),
      );
      return;
    }

    try {
      final response = await radioRepository.getPlaylistSongs(
        playlistId: playlistId,
      );
      final hasErrorStatus = (response.statusCode ?? 200) >= 400 ||
          (response.status?.toLowerCase().contains('error') ?? false);
      if (hasErrorStatus) {
        emit(
          state.copyWith(
            songsStatus: RadioSongsStatus.error,
            songsMessage: response.message ?? 'Unable to load songs',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          songs:
              response.songs.map((song) => RadioSong.fromModel(song)).toList(),
          selectedSongIndex: 0,
          songsStatus: RadioSongsStatus.completed,
          songsMessage: response.message ?? '',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          songsStatus: RadioSongsStatus.error,
          songsMessage: error.toString(),
        ),
      );
    }
  }

  void _onSongSearchChanged(
    RadioSongSearchChanged event,
    Emitter<RadioPlayerState> emit,
  ) {
    emit(state.copyWith(songSearchQuery: event.searchQuery));
  }

  Future<void> _onSongSelected(
    RadioSongSelected event,
    Emitter<RadioPlayerState> emit,
  ) async {
    if (state.songs.isEmpty) {
      return;
    }
    emit(
      state.copyWith(
        selectedSongIndex: event.songIndex,
        hasSelectedSong: true,
        playedSongIndexes: {event.songIndex},
      ),
    );
    await _loadCurrentSong();
    await _audioPlayer.play();
  }

  Future<void> _onSearchSongSelected(
    RadioSearchSongSelected event,
    Emitter<RadioPlayerState> emit,
  ) async {
    if (state.searchSongs.isEmpty) {
      return;
    }
    await _audioPlayer.stop();
    emit(
      state.copyWith(
        songs: List<RadioSong>.from(state.searchSongs),
        selectedSongIndex: event.songIndex,
        isPlaying: false,
        hasSelectedSong: true,
        playedSongIndexes: {event.songIndex},
        duration: Duration.zero,
        position: Duration.zero,
        songsStatus: RadioSongsStatus.completed,
        songsMessage: '',
        songSearchQuery: '',
      ),
    );
    await _loadCurrentSong();
    await _audioPlayer.play();
  }

  Future<void> _onShuffleRequested(
    RadioShuffleRequested event,
    Emitter<RadioPlayerState> emit,
  ) async {
    if (state.songs.isEmpty) {
      return;
    }

    final shuffledSongs = List<RadioSong>.from(state.songs)..shuffle(Random());
    emit(
      state.copyWith(
        songs: shuffledSongs,
        selectedSongIndex: 0,
        hasSelectedSong: true,
        playedSongIndexes: {0},
      ),
    );
    await _loadCurrentSong();
    await _audioPlayer.play();
  }

  Future<void> _onPlayPauseRequested(
    RadioPlayPauseRequested event,
    Emitter<RadioPlayerState> emit,
  ) async {
    if (!state.hasSelectedSong || state.songs.isEmpty) {
      return;
    }
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      if (_audioPlayer.audioSource == null) {
        await _loadCurrentSong();
      }
      await _audioPlayer.play();
    }
  }

  Future<void> _onNextRequested(
    RadioNextRequested event,
    Emitter<RadioPlayerState> emit,
  ) async {
    if (state.songs.isEmpty) {
      return;
    }
    final nextStep = _nextPlaybackStep();
    emit(
      state.copyWith(
        selectedSongIndex: nextStep.index,
        position: Duration.zero,
        hasSelectedSong: true,
        playedSongIndexes: nextStep.playedIndexes,
      ),
    );
    await _loadCurrentSong();
    await _audioPlayer.play();
  }

  Future<void> _onPreviousRequested(
    RadioPreviousRequested event,
    Emitter<RadioPlayerState> emit,
  ) async {
    if (state.songs.isEmpty) {
      return;
    }
    final previousIndex = state.selectedSongIndex == 0
        ? state.songs.length - 1
        : state.selectedSongIndex - 1;
    emit(
      state.copyWith(
        selectedSongIndex: previousIndex,
        position: Duration.zero,
        hasSelectedSong: true,
      ),
    );
    await _loadCurrentSong();
    await _audioPlayer.play();
  }

  Future<void> _onSeekRequested(
    RadioSeekRequested event,
    Emitter<RadioPlayerState> emit,
  ) async {
    await _audioPlayer.seek(event.position);
  }

  void _onPlaybackChanged(
    _RadioPlaybackChanged event,
    Emitter<RadioPlayerState> emit,
  ) {
    emit(state.copyWith(isPlaying: event.isPlaying));
  }

  void _onDurationChanged(
    _RadioDurationChanged event,
    Emitter<RadioPlayerState> emit,
  ) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onPositionChanged(
    _RadioPositionChanged event,
    Emitter<RadioPlayerState> emit,
  ) {
    emit(state.copyWith(position: event.position));
  }

  Future<void> _onSongCompleted(
    _RadioSongCompleted event,
    Emitter<RadioPlayerState> emit,
  ) async {
    if (!state.hasSelectedSong || state.songs.isEmpty) {
      return;
    }

    final nextStep = _nextPlaybackStep();
    emit(
      state.copyWith(
        selectedSongIndex: nextStep.index,
        position: Duration.zero,
        duration: Duration.zero,
        hasSelectedSong: true,
        playedSongIndexes: nextStep.playedIndexes,
      ),
    );
    await _loadCurrentSong();
    await _audioPlayer.play();
  }

  ({int index, Set<int> playedIndexes}) _nextPlaybackStep() {
    final totalSongs = state.songs.length;
    if (totalSongs == 0) {
      return (index: 0, playedIndexes: <int>{});
    }

    var playedIndexes = Set<int>.from(state.playedSongIndexes)
      ..add(state.selectedSongIndex);

    if (playedIndexes.length >= totalSongs) {
      playedIndexes = <int>{};
    }

    for (var offset = 1; offset <= totalSongs; offset++) {
      final candidateIndex = (state.selectedSongIndex + offset) % totalSongs;
      if (!playedIndexes.contains(candidateIndex)) {
        playedIndexes.add(candidateIndex);
        return (index: candidateIndex, playedIndexes: playedIndexes);
      }
    }

    return (
      index: state.selectedSongIndex,
      playedIndexes: {state.selectedSongIndex},
    );
  }

  Future<void> _loadCurrentSong() async {
    if (!state.hasSelectedSong || state.songs.isEmpty) {
      return;
    }
    final audioUrl = state.currentSong.audioUrl;
    if (audioUrl != null && audioUrl.startsWith('http')) {
      await _audioPlayer.setUrl(audioUrl);
      return;
    }
    await _audioPlayer.setAsset(state.currentSong.audioAsset);
  }

  @override
  Future<void> close() async {
    _playlistSearchDebounce?.cancel();
    await _playerStateSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _audioPlayer.dispose();
    return super.close();
  }
}
