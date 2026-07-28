import 'dart:async';
import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:gaanap_admin_new/models/radio/radio_playlist_model.dart';
import 'package:gaanap_admin_new/repository/radio/radio_repository.dart';
import 'package:gaanap_admin_new/services/storage/local_storage.dart';
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
  bool _audioConfigured = false;
  bool _isManuallyChangingSong = false;
  bool _isSongChangeInProgress = false; // New flag to prevent duplicate completes
  dynamic _lastCompletedSongId; // Track last completed song to avoid duplicates

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
  }

  Future<void> _onStarted(
    RadioStarted event,
    Emitter<RadioPlayerState> emit,
  ) async {
    await _configureAudioSession();
    _playerStateSubscription ??=
        _audioPlayer.playerStateStream.listen((playerState) {
      debugPrint("[playerStateStream] new state: playing=${playerState.playing}, processingState=${playerState.processingState}");
      add(_RadioPlaybackChanged(playerState.playing));
      if (playerState.processingState == ProcessingState.completed) {
        debugPrint("[playerStateStream] ProcessingState.completed detected! Adding _RadioSongCompleted() event!");
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
    final selectedPlaylist =
    state.playlists[event.playlistIndex];

    // Check: if we are ALREADY PLAYING this playlist (and songs list is non-empty), do NOT reload!
    if (!state.isSearchPlayback &&
        state.currentPlaylist.id == selectedPlaylist.id &&
        state.songs.isNotEmpty &&
        state.playingPlaylistId == selectedPlaylist.id) {
      debugPrint("[_onPlaylistSelected] Already playing this playlist, skipping reload!");
      return;
    }

    // await _audioPlayer.stop();
    emit(
      state.copyWith(
        selectedPlaylistIndex: event.playlistIndex,
        songs: const [],
        selectedSongIndex: 0,
        // isPlaying: false,
        // hasSelectedSong: false,
        playedSongIndexes: {},
        // duration: Duration.zero,
        // position: Duration.zero,
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
      var songs =
      response.songs.map((song) => RadioSong.fromModel(song)).toList();
      final cached =
      await LocalStorage.readModel(
        'radio_playlist_$playlistId',
      );
      if (cached != null) {
        final cachedIds =
        List<dynamic>.from(cached['songs'] ?? []);

        final reorderedSongs = <RadioSong>[];

        for (final id in cachedIds) {
          try {
            reorderedSongs.add(
              songs.firstWhere(
                    (song) => song.id.toString() == id.toString(),
              ),
            );
          } catch (_) {}
        }

        final remainingSongs =
        songs.where(
              (song) => !cachedIds.contains(song.id),
        );

        songs = [
          ...reorderedSongs,
          ...remainingSongs,
        ];
      }
      emit(
        state.copyWith(
          songs:songs,
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

    // Set flags to prevent duplicate song completion event
    _isManuallyChangingSong = true;
    _isSongChangeInProgress = true;
    _lastCompletedSongId = null;
    debugPrint("[_onSongSelected] Setting manual change and song change in progress flags and resetting _lastCompletedSongId");

    final selectedSong = state.songs[event.songIndex];

    final reorderedSongs = [
      selectedSong,
      ...state.songs.where((e) => e != selectedSong),
    ];

    emit(
      state.copyWith(
        songs: reorderedSongs,
        selectedSongIndex: 0,
        hasSelectedSong: true,
        playedSongIndexes: {0},
        playingPlaylistId: state.currentPlaylist.id,
        playingSong: reorderedSongs.first,
        isSearchPlayback: false, // Ensure not in search playback mode when selecting from playlist
      ),
    );

    await _saveCurrentQueue(reorderedSongs);

    // Clear flags BEFORE calling _playSong
    _isManuallyChangingSong = false;
    _isSongChangeInProgress = false;
    debugPrint("[_onSongSelected] Cleared manual change and song change in progress flags");

    await _playSong(reorderedSongs.first);
  }

  Future<void> _onSearchSongSelected(
    RadioSearchSongSelected event,
    Emitter<RadioPlayerState> emit,
  ) async {
    if (state.searchSongs.isEmpty) {
      return;
    }

    // Set flags to prevent duplicate song completion event
    _isManuallyChangingSong = true;
    _isSongChangeInProgress = true;
    _lastCompletedSongId = null;
    debugPrint("[_onSearchSongSelected] Setting manual change and song change in progress flags and resetting _lastCompletedSongId");

    final selectedSong =
    state.searchSongs[event.songIndex];


    emit(
      state.copyWith(
        queueBeforeSearch:
        List<RadioSong>.from(state.songs),
        songs: [selectedSong],
        selectedSongIndex: 0,
        hasSelectedSong: true,
        isSearchPlayback: true,
        playingSearchSongId: selectedSong.id,
        playingPlaylistId: -1,
        playingSong: selectedSong,
      ),
    );

    // Clear flags BEFORE calling _playSong
    _isManuallyChangingSong = false;
    _isSongChangeInProgress = false;
    debugPrint("[_onSearchSongSelected] Cleared manual change and song change in progress flags");

    await _playSong(selectedSong);
  }

  Future<void> _onSongAddToQueueRequested(
      RadioSongAddToQueueRequested event,
      Emitter<RadioPlayerState> emit,
      ) async {
    debugPrint("[_onSongAddToQueueRequested] CALLED!");
    debugPrint("[_onSongAddToQueueRequested] event.song: ${event.song.title}");
    debugPrint("[_onSongAddToQueueRequested] isSearchPlayback: ${state.isSearchPlayback}");
    if (state.isSearchPlayback) {
      debugPrint("[_onSongAddToQueueRequested] search playback, returning early");
      return;
    }

    final queuedSongs = List<RadioSong>.from(state.songs);
    debugPrint("[_onSongAddToQueueRequested] current songs: ${queuedSongs.map((e) => e.title).toList()}");

    // Check if song already exists
    final existingIndex = queuedSongs.indexWhere((e) => e.id == event.song.id);
    if (existingIndex != -1) {
      debugPrint("[_onSongAddToQueueRequested] song exists at index $existingIndex, moving it to position 1");
      // Remove existing song first
      queuedSongs.removeAt(existingIndex);
    }

    // Insert at position 1 (after current song) or 0 if empty
    final insertPosition = queuedSongs.isNotEmpty ? 1 : 0;
    debugPrint("[_onSongAddToQueueRequested] inserting song at position $insertPosition");

    queuedSongs.insert(insertPosition, event.song);

    debugPrint("[_onSongAddToQueueRequested] BEFORE EMIT - songs: ${state.songs.map((s) => s.title).toList()}, adding/moving: ${event.song.title} at position $insertPosition");

    emit(
      state.copyWith(
        songs: queuedSongs,
        songsStatus: RadioSongsStatus.completed,
      ),
    );

    debugPrint("[_onSongAddToQueueRequested] AFTER EMIT - new songs: ${queuedSongs.map((s) => s.title).toList()}");

    await _saveCurrentQueue(queuedSongs);

    debugPrint(
      "Queue => ${queuedSongs.map((e) => e.title).toList()}",
    );
  }

  Future<void> _onShuffleRequested(
    RadioShuffleRequested event,
    Emitter<RadioPlayerState> emit,
  ) async {
    if (state.songs.isEmpty) {
      return;
    }

    // Set flags to prevent duplicate song completion event
    _isManuallyChangingSong = true;
    _isSongChangeInProgress = true;
    _lastCompletedSongId = null;
    debugPrint("[_onShuffleRequested] Setting manual change and song change in progress flags and resetting _lastCompletedSongId");

    final shuffledSongs = List<RadioSong>.from(state.songs)..shuffle(Random());
    emit(
      state.copyWith(
        songs: shuffledSongs,
        selectedSongIndex: 0,
        hasSelectedSong: true,
        playedSongIndexes: {0},
        playingPlaylistId: state.currentPlaylist.id,
        isSearchPlayback: false, // Make sure we're not in search playback mode
        playingSong: shuffledSongs.first,
      ),
    );
    await _saveCurrentQueue(shuffledSongs);

    // Clear flags BEFORE calling _playSong
    _isManuallyChangingSong = false;
    _isSongChangeInProgress = false;
    debugPrint("[_onShuffleRequested] Cleared manual change and song change in progress flags");

    await _playSong(shuffledSongs.first);
  }

  bool canAddToQueue() {
    return state.playingPlaylistId ==
        state.currentPlaylist.id;
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

    // Set flags to prevent duplicate song completion events
    _isManuallyChangingSong = true;
    _isSongChangeInProgress = true;
    _lastCompletedSongId = null;
    debugPrint("[_onNextRequested] Setting manual change and song change in progress flags and resetting _lastCompletedSongId");

    final updatedSongs =
    List<RadioSong>.from(state.songs);

    final currentSong =
    updatedSongs.removeAt(0);

    updatedSongs.add(currentSong);

    debugPrint("[_onNextRequested] BEFORE EMIT - songs: ${state.songs.map((s) => s.title).toList()}");
    debugPrint("[_onNextRequested] currentSong: ${currentSong.title}, nextSong: ${updatedSongs.first.title}");

    emit(
      state.copyWith(
        songs: updatedSongs,
        selectedSongIndex: 0,
        position: Duration.zero,
        duration: Duration.zero,
        playingSong: updatedSongs.first,
        isSearchPlayback: false, // Ensure not in search playback mode when playing next from playlist
      ),
    );

    debugPrint("[_onNextRequested] AFTER EMIT - new songs: ${updatedSongs.map((s) => s.title).toList()}");

    await _saveCurrentQueue(updatedSongs);

    // Clear flags BEFORE calling _playSong
    _isManuallyChangingSong = false;
    _isSongChangeInProgress = false;
    debugPrint("[_onNextRequested] Cleared manual change and song change in progress flags");

    await _playSong(
      updatedSongs.first,
    );
  }

  Future<void> _onPreviousRequested(
    RadioPreviousRequested event,
    Emitter<RadioPlayerState> emit,
  ) async {
    if (state.songs.isEmpty) {
      return;
    }

    // Set flags to prevent duplicate song completion event
    _isManuallyChangingSong = true;
    _isSongChangeInProgress = true;
    _lastCompletedSongId = null;
    debugPrint("[_onPreviousRequested] Setting manual change and song change in progress flags and resetting _lastCompletedSongId");

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
        isSearchPlayback: false, // Ensure not in search playback mode when playing previous from playlist
      ),
    );
    await Future.delayed(
      const Duration(milliseconds: 50),
    );
    await _saveCurrentQueue(updatedSongs);

    // Clear flags BEFORE calling _playSong
    _isManuallyChangingSong = false;
    _isSongChangeInProgress = false;
    debugPrint("[_onPreviousRequested] Cleared manual change and song change in progress flags");

    await _playSong(updatedSongs.first);
  }

  Future<void> _onSeekRequested(
    RadioSeekRequested event,
    Emitter<RadioPlayerState> emit,
  ) async {
    debugPrint("[_onSeekRequested] ENTERED, requested: ${event.position}");
    if (!state.hasSelectedSong || state.songs.isEmpty) {
      debugPrint("[_onSeekRequested] no selected song or songs empty, returning");
      return;
    }

    // Reset last completed song id when user seeks, in case seek triggers a completion event
    _lastCompletedSongId = null;
    debugPrint("[_onSeekRequested] resetting _lastCompletedSongId to null to allow completion after seek");

    final duration = _audioPlayer.duration ?? state.duration;
    debugPrint("[_onSeekRequested] duration: $duration");
    if (duration <= Duration.zero) {
      debugPrint("[_onSeekRequested] duration <= 0, returning");
      return;
    }

    final safeEndPosition = duration > const Duration(milliseconds: 500)
        ? duration - const Duration(milliseconds: 500)
        : Duration.zero;
    final requestedPosition =
        event.position < Duration.zero ? Duration.zero : event.position;
    final seekPosition = requestedPosition > safeEndPosition
        ? safeEndPosition
        : requestedPosition;

    debugPrint("[_onSeekRequested] seekPosition: $seekPosition");
    emit(state.copyWith(position: seekPosition));
    await _audioPlayer.seek(seekPosition);
    debugPrint("[_onSeekRequested] seek complete, isPlaying: ${_audioPlayer.playing}, audioSource: ${_audioPlayer.audioSource}");
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
      ) async
  {
    debugPrint("[_onSongCompleted] ENTERED!");
    if (!state.hasSelectedSong || state.songs.isEmpty) {
      debugPrint("[_onSongCompleted] no selected song or songs empty, returning");
      return;
    }

    final currentSong = state.songs.first;
    debugPrint("[_onSongCompleted] currentSong: ${currentSong.title}, id: ${currentSong.id}");
    debugPrint("[_onSongCompleted] _lastCompletedSongId: $_lastCompletedSongId, _isSongChangeInProgress: $_isSongChangeInProgress");

    // Skip if user is manually changing song OR a song change is in progress
    if (_isManuallyChangingSong || _isSongChangeInProgress) {
      debugPrint("[_onSongCompleted] Skipping - manual song change OR song change in progress");
      return;
    }

    // Skip if we already processed this song completion
    if (_lastCompletedSongId == currentSong.id) {
      debugPrint("[_onSongCompleted] Skipping - already completed this song id: ${currentSong.id}");
      return;
    }

    // Set flags that we're in a song change (auto)
    _isSongChangeInProgress = true;
    _lastCompletedSongId = currentSong.id;
    debugPrint("[_onSongCompleted] setting song change in progress flag and _lastCompletedSongId to ${_lastCompletedSongId}");

    if (state.isSearchPlayback) {

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

          playingSearchSongId:
          state.currentSong.id ?? 0,
          playingSong: null,
        ),
      );

      _isSongChangeInProgress = false; // clear flag
      return;
    }

    final updatedSongs = List<RadioSong>.from(state.songs);

    final completedSong = updatedSongs.removeAt(0);

    updatedSongs.add(completedSong);
    final nextSong = updatedSongs.first;

    debugPrint("[_onSongCompleted] BEFORE EMIT - songs: ${state.songs.map((s) => s.title).toList()}");
    debugPrint("[_onSongCompleted] completedSong: ${completedSong.title}, nextSong: ${nextSong.title}");

    emit(
      state.copyWith(
        songs: updatedSongs,
        selectedSongIndex: 0,
        position: Duration.zero,
        duration: Duration.zero,
        playingSong: nextSong,
        isSearchPlayback: false, // Ensure not in search playback mode when song completes
      ),
    );

    debugPrint("[_onSongCompleted] AFTER EMIT - new songs: ${updatedSongs.map((s) => s.title).toList()}");

    await Future.delayed(
      const Duration(milliseconds: 100),
    );

    await _saveCurrentQueue(updatedSongs);

    // Clear the song change flag BEFORE calling _playSong, so next song can trigger completion
    _isSongChangeInProgress = false;
    debugPrint("[_onSongCompleted] cleared song change in progress flag");

    await _playSong(nextSong);
  }


  Future<void> _playSong(
      RadioSong song,
      ) async {
    debugPrint("[_playSong] START - song: ${song.title}");
    _lastCompletedSongId = null; // Reset last completed song id when starting new song
    debugPrint("[_playSong] resetting _lastCompletedSongId to null");
    await _audioPlayer.stop();

    if (song.audioUrl != null &&
        song.audioUrl!.startsWith('http')) {
      debugPrint("[_playSong] Setting URL: ${song.audioUrl}");
      await _audioPlayer.setUrl(song.audioUrl!);
    } else {
      debugPrint("[_playSong] Setting asset: ${song.audioAsset}");
      await _audioPlayer.setAsset(song.audioAsset);
    }
    await _audioPlayer.play();
    debugPrint("[_playSong] COMPLETE - audio should be playing: ${song.title}");
  }

  Future<void> _configureAudioSession() async {
    if (_audioConfigured) return;

    try {
      final session = await AudioSession.instance;

      await session.configure(
        const AudioSessionConfiguration.music(),
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
  }  @override
  Future<void> close() async {
    _playlistSearchDebounce?.cancel();
    await _playerStateSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _audioPlayer.dispose();
    return super.close();
  }
}
