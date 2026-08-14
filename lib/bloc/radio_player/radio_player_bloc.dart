import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:gaanap_admin_new/models/radio/radio_playlist_model.dart';
import 'package:gaanap_admin_new/repository/radio/radio_repository.dart';
import 'package:gaanap_admin_new/services/storage/local_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
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

  bool _audioConfigured = false;
  bool _isManuallyChangingSong = false;
  bool _isSongChangeInProgress = false;
  dynamic _lastCompletedSongId;
  dynamic _currentPlayingSongId;
  bool _isAppInBackground = false;

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
    on<RadioSongAddToQueueRequested>(_onSongAddToQueueRequested);
    on<RadioShuffleRequested>(_onShuffleRequested);
    on<RadioPlayPauseRequested>(_onPlayPauseRequested);
    on<RadioNextRequested>(_onNextRequested);
    on<RadioPreviousRequested>(_onPreviousRequested);
    on<RadioSeekRequested>(_onSeekRequested);
    on<_RadioPlaybackChanged>(_onPlaybackChanged);
    on<_RadioDurationChanged>(_onDurationChanged);
    on<_RadioPositionChanged>(_onPositionChanged);
    on<_RadioSongCompleted>(_onSongCompleted);
    on<RadioAppLifecycleChanged>(_onAppLifecycleChanged);

  }


  Future<void> _onAppLifecycleChanged(
      RadioAppLifecycleChanged event,
      Emitter<RadioPlayerState> emit,
      ) async {
    if (event.state == AppLifecycleState.paused ||
        event.state == AppLifecycleState.inactive ||
        event.state == AppLifecycleState.detached) {
      debugPrint("App State ::: ${event.state}");
      _isAppInBackground= true;
      // if (_audioPlayer.playing) {
      //   await _audioPlayer.pause();
      // }
    }

    if (event.state == AppLifecycleState.resumed) {
      // Only resume if that is your desired behavior.
      // If you want manual resume, leave this empty.
      _isAppInBackground= false;

    }
    debugPrint("_isAppInBackground::: ${_isAppInBackground}");

  }

  Future<void> _onStarted(
      RadioStarted event,
      Emitter<RadioPlayerState> emit,
      ) async {
    await _configureAudioSession();

    _playerStateSubscription ??= _audioPlayer.playerStateStream.listen((playerState) {
      debugPrint(
        "[playerStateStream] playing=${playerState.playing}, processingState=${playerState.processingState}, currentSongId=$_currentPlayingSongId",
      );

      add(_RadioPlaybackChanged(playerState.playing));

      if (playerState.processingState == ProcessingState.completed) {
        final completedSongId = _currentPlayingSongId ??
            (state.playingSong ?? (state.songs.isNotEmpty ? state.songs.first : null))?.id;

        debugPrint(
          "[playerStateStream] completed detected, adding _RadioSongCompleted(songId=$completedSongId)",
        );

        add(_RadioSongCompleted(completedSongId));
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
    final query = searchQuery.trim();
    _playlistSearchDebounce?.cancel();

    if (query.isEmpty) {
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

      if (requestId != _playlistSearchRequestId) return;

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
      if (requestId != _playlistSearchRequestId) return;

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
    final selectedPlaylist = state.playlists[event.playlistIndex];

    if (!state.isSearchPlayback &&
        state.currentPlaylist.id == selectedPlaylist.id &&
        state.songs.isNotEmpty &&
        state.playingPlaylistId == selectedPlaylist.id) {
      debugPrint("[_onPlaylistSelected] Already playing this playlist, skipping reload!");
      return;
    }

    emit(
      state.copyWith(
        selectedPlaylistIndex: event.playlistIndex,
        songs: const [],
        selectedSongIndex: 0,
        playedSongIndexes: {},
        songsStatus: RadioSongsStatus.loading,
        songsMessage: '',
        songSearchQuery: '',
        hasSelectedSong: false,
        playingSong: null,
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

      var songs = response.songs.map((song) => RadioSong.fromModel(song)).toList();

      final cached = await LocalStorage.readModel('radio_playlist_$playlistId');
      if (cached != null) {
        final cachedIds = List<dynamic>.from(cached['songs'] ?? []);
        final reorderedSongs = <RadioSong>[];

        for (final id in cachedIds) {
          try {
            reorderedSongs.add(
              songs.firstWhere((song) => song.id.toString() == id.toString()),
            );
          } catch (_) {}
        }

        final remainingSongs = songs.where(
              (song) => !cachedIds.contains(song.id),
        );

        songs = [...reorderedSongs, ...remainingSongs];
      }

      emit(
        state.copyWith(
          songs: songs,
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
    if (state.songs.isEmpty) return;

    _isManuallyChangingSong = true;
    _isSongChangeInProgress = true;
    _lastCompletedSongId = null;

    final selectedSong = state.songs[event.songIndex];
    final reorderedSongs = [
      selectedSong,
      ...state.songs.where((e) => e.id != selectedSong.id),
    ];

    emit(
      state.copyWith(
        songs: reorderedSongs,
        selectedSongIndex: 0,
        hasSelectedSong: true,
        playedSongIndexes: {0},
        playingPlaylistId: state.currentPlaylist.id,
        playingSong: reorderedSongs.first,
        isSearchPlayback: false,
      ),
    );

    await _saveCurrentQueue(reorderedSongs);
    _isManuallyChangingSong = false;
    _isSongChangeInProgress = false;
    await _playSong(reorderedSongs.first);


  }

  Future<void> _onSearchSongSelected(
      RadioSearchSongSelected event,
      Emitter<RadioPlayerState> emit,
      ) async {
    if (state.searchSongs.isEmpty) return;

    _isManuallyChangingSong = true;
    _isSongChangeInProgress = true;
    _lastCompletedSongId = null;

    final selectedSong = state.searchSongs[event.songIndex];

    emit(
      state.copyWith(
        queueBeforeSearch: List<RadioSong>.from(state.songs),
        songs: [selectedSong],
        selectedSongIndex: 0,
        hasSelectedSong: true,
        isSearchPlayback: true,
        playingSearchSongId: selectedSong.id,
        playingPlaylistId: -1,
        playingSong: selectedSong,
      ),
    );
    _isManuallyChangingSong = false;
    _isSongChangeInProgress = false;
    await _playSong(selectedSong);


  }

  Future<void> _onSongAddToQueueRequested(
      RadioSongAddToQueueRequested event,
      Emitter<RadioPlayerState> emit,
      ) async {
    if (state.isSearchPlayback) return;
    if (state.songs.isEmpty) return;

    final queuedSongs = List<RadioSong>.from(state.songs);
    final existingIndex = queuedSongs.indexWhere((e) => e.id == event.song.id);

    if (existingIndex != -1) {
      queuedSongs.removeAt(existingIndex);
    }

    final insertPosition = queuedSongs.isNotEmpty ? 1 : 0;
    queuedSongs.insert(insertPosition, event.song);

    emit(
      state.copyWith(
        songs: queuedSongs,
        songsStatus: RadioSongsStatus.completed,
      ),
    );

    await _saveCurrentQueue(queuedSongs);
  }

  Future<void> _onShuffleRequested(
      RadioShuffleRequested event,
      Emitter<RadioPlayerState> emit,
      ) async {
    if (state.songs.isEmpty) return;

    _isManuallyChangingSong = true;
    _isSongChangeInProgress = true;
    _lastCompletedSongId = null;

    final shuffledSongs = List<RadioSong>.from(state.songs)..shuffle(Random());

    emit(
      state.copyWith(
        songs: shuffledSongs,
        selectedSongIndex: 0,
        hasSelectedSong: true,
        playedSongIndexes: {0},
        playingPlaylistId: state.currentPlaylist.id,
        isSearchPlayback: false,
        playingSong: shuffledSongs.first,
      ),
    );

    await _saveCurrentQueue(shuffledSongs);
    _isManuallyChangingSong = false;
    _isSongChangeInProgress = false;
    await _playSong(shuffledSongs.first);


  }

  bool canAddToQueue() {
    return state.playingPlaylistId == state.currentPlaylist.id;
  }

  Future<void> _onPlayPauseRequested(
      RadioPlayPauseRequested event,
      Emitter<RadioPlayerState> emit,
      ) async {
    if (!state.hasSelectedSong || state.songs.isEmpty) return;

    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      if (_audioPlayer.audioSource == null) {
        await _playSong(state.songs.first);
      } else {
        await _audioPlayer.play();
      }
    }
  }

  Future<void> _onNextRequested(
      RadioNextRequested event,
      Emitter<RadioPlayerState> emit,
      ) async {
    if (state.songs.isEmpty) return;

    _isManuallyChangingSong = true;
    _isSongChangeInProgress = true;
    _lastCompletedSongId = null;

    final updatedSongs = List<RadioSong>.from(state.songs);
    final currentSong = updatedSongs.removeAt(0);
    updatedSongs.add(currentSong);

    emit(
      state.copyWith(
        songs: updatedSongs,
        selectedSongIndex: 0,
        position: Duration.zero,
        duration: Duration.zero,
        playingSong: updatedSongs.first,
        isSearchPlayback: false,
        hasSelectedSong: true,
      ),
    );

    await _saveCurrentQueue(updatedSongs);
    _isManuallyChangingSong = false;
    _isSongChangeInProgress = false;
    await _playSong(updatedSongs.first);


  }

  Future<void> _onPreviousRequested(
      RadioPreviousRequested event,
      Emitter<RadioPlayerState> emit,
      ) async {
    if (state.songs.isEmpty) return;

    _isManuallyChangingSong = true;
    _isSongChangeInProgress = true;
    _lastCompletedSongId = null;

    final updatedSongs = List<RadioSong>.from(state.songs);
    final lastSong = updatedSongs.removeLast();
    updatedSongs.insert(0, lastSong);

    emit(
      state.copyWith(
        songs: updatedSongs,
        selectedSongIndex: 0,
        position: Duration.zero,
        hasSelectedSong: true,
        playingSong: updatedSongs.first,
        isSearchPlayback: false,
      ),
    );

    await _saveCurrentQueue(updatedSongs);
    _isManuallyChangingSong = false;
    _isSongChangeInProgress = false;
    await _playSong(updatedSongs.first);


  }

  Future<void> _onSeekRequested(
      RadioSeekRequested event,
      Emitter<RadioPlayerState> emit,
      ) async {
    if (!state.hasSelectedSong || state.songs.isEmpty) return;

    final duration = _audioPlayer.duration ?? state.duration;
    if (duration <= Duration.zero) return;

    final requestedPosition =
    event.position < Duration.zero ? Duration.zero : event.position;

    final safeEndPosition = duration > const Duration(milliseconds: 500)
        ? duration - const Duration(milliseconds: 500)
        : Duration.zero;

    final seekPosition = requestedPosition > safeEndPosition
        ? safeEndPosition
        : requestedPosition;

    _lastCompletedSongId = null;

    emit(state.copyWith(position: seekPosition));
    await _audioPlayer.seek(seekPosition);
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
    debugPrint("[_onSongCompleted] ENTERED");

    // if(_isAppInBackground){
    //   debugPrint("[_onSongCompleted] App is in background");
    //   return;
    //
    // }
    if (!state.hasSelectedSong || state.songs.isEmpty) {
      debugPrint("[_onSongCompleted] no selected song or songs empty");
      return;
    }

    if (_isManuallyChangingSong) {
      debugPrint("[_onSongCompleted] skipped because manual song change in progress");
      return;
    }
    final currentSong = state.songs.first;
    final completedSongId = event.songId ?? _currentPlayingSongId ?? currentSong.id;

    debugPrint(
      "[_onSongCompleted] currentSong=${currentSong.title}, currentSongId=${currentSong.id}, completedSongId=$completedSongId, lastCompleted=$_lastCompletedSongId",
    );

    if (completedSongId != currentSong.id) {
      debugPrint("[_onSongCompleted] skipped because completed song is not current song");
      return;
    }

    if (_lastCompletedSongId == completedSongId) {
      debugPrint("[_onSongCompleted] skipped because already handled");
      return;
    }

    _isSongChangeInProgress = true;
    _lastCompletedSongId = completedSongId;

    if (state.isSearchPlayback) {
      debugPrint("[_onSongCompleted] search playback finished, restoring queue");

      await _audioPlayer.stop();

      emit(
        state.copyWith(
          songs: state.queueBeforeSearch,
          queueBeforeSearch: const [],
          isPlaying: false,
          isSearchPlayback: false,
          hasSelectedSong: false,
          duration: Duration.zero,
          position: Duration.zero,
          playingSearchSongId: null,
          playingSong: null,
        ),
      );

      _currentPlayingSongId = null;
      _isSongChangeInProgress = false;
      return;
    }

    final updatedSongs = List<RadioSong>.from(state.songs);
    final finishedSong = updatedSongs.removeAt(0);
    updatedSongs.add(finishedSong);

    final nextSong = updatedSongs.first;

    debugPrint(
      "[_onSongCompleted] finished=${finishedSong.title}, next=${nextSong.title}",
    );

    emit(
      state.copyWith(
        songs: updatedSongs,
        selectedSongIndex: 0,
        position: Duration.zero,
        duration: Duration.zero,
        playingSong: nextSong,
        isSearchPlayback: false,
        hasSelectedSong: true,
      ),
    );

    await _saveCurrentQueue(updatedSongs);
    await _playSong(nextSong);

    _isSongChangeInProgress = false;
    debugPrint("[_onSongCompleted] done");
  }

  // Future<void> _playSong(RadioSong song) async {
  //   debugPrint("[_playSong] START song=${song.title}, id=${song.id}");
  //
  //   _currentPlayingSongId = song.id;
  //
  //   try {
  //     if (song.audioUrl != null && song.audioUrl!.startsWith('http')) {
  //       debugPrint("[_playSong] loading url=${song.audioUrl}");
  //       await _audioPlayer.setUrl(song.audioUrl!);
  //     } else {
  //       debugPrint("[_playSong] loading asset=${song.audioAsset}");
  //       await _audioPlayer.setAsset(song.audioAsset);
  //     }
  //
  //     await _audioPlayer.play();
  //
  //     debugPrint("[_playSong] PLAYING song=${song.title}");
  //   } catch (e) {
  //     debugPrint("[_playSong] ERROR: $e");
  //     _isSongChangeInProgress = false;
  //   }
  // }

  Future<void> _playSong(RadioSong song) async {
    debugPrint("[_playSong] START song=${song.title}, id=${song.id}");

    _currentPlayingSongId = song.id;

    try {
      // Create MediaItem for just_audio_background
      final mediaItem = MediaItem(
        id: song.id?.toString() ?? '',
        title: song.title,
        artist: song.artist,
        album: song.movie.isNotEmpty ? song.movie : null,
        duration: _parseDurationFromLabel(song.durationLabel), // helper below
        artUri: song.imageUrl != null && song.imageUrl!.startsWith('http')
            ? Uri.parse(song.imageUrl!)
            : null,
      );

      final sourceUrl = song.audioUrl != null && song.audioUrl!.startsWith('http')
          ? song.audioUrl!
          : null;

      final AudioSource audioSource;

      if (sourceUrl != null) {
        audioSource = AudioSource.uri(
          Uri.parse(sourceUrl),
          tag: mediaItem,
        );
      } else {
        // For assets, use asset URI
        final assetUri = Uri.parse('asset://${song.audioAsset}');
        audioSource = AudioSource.uri(
          assetUri,
          tag: mediaItem,
        );
      }

      await _audioPlayer.setAudioSource(audioSource);
      await _audioPlayer.play();

      await AudioService.updateMediaItem(mediaItem);

      debugPrint("[_playSong] PLAYING song=${song.title}");
    } catch (e) {
      debugPrint("[_playSong] ERROR: $e");
    }
  }

  Duration _parseDurationFromLabel(String label) {
    // Expect something like "03:45" or "3:45"
    final parts = label.split(':');
    if (parts.length == 2) {
      try {
        final minutes = int.parse(parts[0].trim());
        final seconds = int.parse(parts[1].trim());
        return Duration(minutes: minutes, seconds: seconds);
      } catch (_) {}
    }
    return Duration.zero;
  }

  Future<void> _configureAudioSession() async {
    if (_audioConfigured) return;

    try {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          // androidWillPauseWhenDuckedWithGuidance: false,
        ),
      );
      _audioConfigured = true;
    } catch (e) {
      debugPrint('Audio session config failed: $e');
    }
  }

  Future<void> _saveCurrentQueue(List<RadioSong> songs) async {
    final playlistId = state.currentPlaylist.id;
    if (playlistId == null) return;

    await LocalStorage.saveModel(
      'radio_playlist_$playlistId',
      {
        'playlistId': playlistId,
        'currentSongId': songs.isNotEmpty ? songs.first.id : null,
        'songs': songs.map((e) => e.id).toList(),
      },
    );
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