import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaanap_admin_new/bloc/radio_player/radio_player_bloc.dart';
import 'package:gaanap_admin_new/main.dart';
import 'package:gaanap_admin_new/repository/radio/radio_repository.dart';
import 'package:gaanap_admin_new/utils/Utils.dart';
import 'package:gaanap_admin_new/views/radio/radio_player_screen.dart';
import 'package:gaanap_admin_new/views/radio/radio_playlist_songs_screen.dart';
import 'package:gaanap_admin_new/views/radio/radio_theme.dart';
import 'package:gaanap_admin_new/views/radio/widgets/radio_mini_player.dart';
import 'package:gaanap_admin_new/views/radio/widgets/radio_song_options_sheet.dart';

class RadioPlaylistScreen extends StatelessWidget {
  const RadioPlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RadioPlayerBloc(radioRepository: getit<RadioRepository>())
        ..add(RadioStarted()),
      child: const RadioPlaylistView(),
    );
  }
}

class RadioPlaylistView extends StatelessWidget {
  const RadioPlaylistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RadioThemeColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _RadioHeader(title: 'Playlists', showSearch: true),
            BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
              buildWhen: (previous, current) =>
                  previous.isPlaylistSongSearchVisible !=
                      current.isPlaylistSongSearchVisible ||
                  previous.searchQuery != current.searchQuery,
              builder: (context, state) {
                final isSongSearchActive = state.searchQuery.trim().isNotEmpty;
                return Column(
                  children: [
                    if (state.isPlaylistSongSearchVisible)
                      const _SongSearchField(),
                    if (!isSongSearchActive) const _PlaylistSearchField(),
                  ],
                );
              },
            ),
            Expanded(
              child: BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
                builder: (context, state) {
                  if (state.searchQuery.trim().isNotEmpty) {
                    return _SearchSongResults(state: state);
                  }

                  if (state.playlistStatus == RadioPlaylistStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: RadioThemeColors.navy,
                      ),
                    );
                  }

                  if (state.playlistStatus == RadioPlaylistStatus.error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Text(
                          state.playlistMessage.isEmpty
                              ? 'Unable to load playlists'
                              : state.playlistMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: RadioThemeColors.navy,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }

                  final playlists = state.filteredPlaylists;
                  if (playlists.isEmpty) {
                    return const Center(
                      child: Text(
                        'No playlists found',
                        style: TextStyle(
                          color: RadioThemeColors.navy,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return _PlaylistTile(
                        playlist: playlist,
                        onTap: () {
                          final originalIndex =
                              state.playlists.indexOf(playlist);
                          context
                              .read<RadioPlayerBloc>()
                              .add(RadioPlaylistSelected(originalIndex));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<RadioPlayerBloc>(),
                                child: const RadioPlaylistSongsScreen(),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: playlists.length,
                  );
                },
              ),
            ),
            const RadioMiniPlayer(),
          ],
        ),
      ),
    );
  }
}

class _PlaylistSearchField extends StatelessWidget {
  const _PlaylistSearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: RadioThemeColors.row,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: RadioThemeColors.navy,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) {
                context
                    .read<RadioPlayerBloc>()
                    .add(RadioPlaylistSearchChanged(value));
              },
              style: const TextStyle(
                color: RadioThemeColors.navy,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'Search playlists',
                hintStyle: TextStyle(
                  color: RadioThemeColors.softText,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongSearchField extends StatefulWidget {
  const _SongSearchField();

  @override
  State<_SongSearchField> createState() => _SongSearchFieldState();
}

class _SongSearchFieldState extends State<_SongSearchField> {
  static const _searchOptions = {
    'song': 'Song Name',
    'movie_name': 'Movie Name',
    'composer1': 'Composer',
    'singer1': 'Singer',
    'lyricist': 'Lyricist',
    'year': 'Year',
    'genre1': 'Genre',
  };

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
      buildWhen: (previous, current) =>
          previous.playlistSearchBy != current.playlistSearchBy,
      builder: (context, state) {
        return Container(
          height: 46,
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: RadioThemeColors.row,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 116,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state.playlistSearchBy,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: RadioThemeColors.navy,
                      size: 20,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    dropdownColor: RadioThemeColors.row,
                    style: const TextStyle(
                      color: RadioThemeColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    items: _searchOptions.entries
                        .map(
                          (entry) => DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      _searchController.clear();

                      context.read<RadioPlayerBloc>().add(
                            const RadioPlaylistSongSearchChanged(""),
                          );

                      if (value == null) return;

                      context.read<RadioPlayerBloc>().add(
                            RadioPlaylistSearchByChanged(value),
                          );
                    },
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: RadioThemeColors.navy.withValues(alpha: 0.18),
              ),
              const Icon(
                Icons.search_rounded,
                color: RadioThemeColors.navy,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<RadioPlayerBloc>().add(
                          RadioPlaylistSongSearchChanged(value),
                        );
                  },
                  style: const TextStyle(
                    color: RadioThemeColors.navy,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search songs',
                    hintStyle: TextStyle(
                      color: RadioThemeColors.softText,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchSongResults extends StatelessWidget {
  final RadioPlayerState state;

  const _SearchSongResults({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.searchSongsStatus == RadioSongsStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: RadioThemeColors.navy,
        ),
      );
    }

    if (state.searchSongsStatus == RadioSongsStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            state.searchSongsMessage.isEmpty
                ? 'Unable to search songs'
                : state.searchSongsMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: RadioThemeColors.navy,
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    if (state.searchSongs.isEmpty) {
      return const Center(
        child: Text(
          'No songs found',
          style: TextStyle(
            color: RadioThemeColors.navy,
            fontSize: 15,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      itemCount: state.searchSongs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final song = state.searchSongs[index];
        return _SearchSongTile(
          song: song,
          onTap: () {
            context.read<RadioPlayerBloc>().add(RadioSearchSongSelected(index));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<RadioPlayerBloc>(),
                  child: const RadioPlayerScreen(),
                ),
              ),
            );
          },
          onMoreTap: () => showRadioSongOptionsSheet(context, song),
        );
      },
    );
  }
}

class _RadioHeader extends StatelessWidget {
  final String title;
  final bool showSearch;

  const _RadioHeader({
    required this.title,
    required this.showSearch,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(
              Icons.logout,
              color: RadioThemeColors.navy,
              size: 24,
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: RadioThemeColors.navy,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (showSearch)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
                buildWhen: (previous, current) =>
                    previous.isPlaylistSongSearchVisible !=
                    current.isPlaylistSongSearchVisible,
                builder: (context, state) {
                  return IconButton(
                    onPressed: () {
                      context.read<RadioPlayerBloc>().add(
                            RadioPlaylistSongSearchVisibilityChanged(
                              !state.isPlaylistSongSearchVisible,
                            ),
                          );
                    },
                    icon: Icon(
                      state.isPlaylistSongSearchVisible
                          ? Icons.close_rounded
                          : Icons.search_rounded,
                      color: RadioThemeColors.navy,
                      size: 30,
                    ),
                  );
                },
              ),
            )
          else
            const SizedBox(width: 18),
        ],
      ),
    );
  }
}

class _SearchSongTile extends StatelessWidget {
  final RadioSong song;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const _SearchSongTile({
    required this.song,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RadioThemeColors.row,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 76,
          child: Row(
            children: [
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _SearchSongArtwork(song: song),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RadioThemeColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        song.artist,
                        song.movie,
                      ].where((value) => value.trim().isNotEmpty).join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RadioThemeColors.navy,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (song.durationLabel.isNotEmpty)
                Text(
                  song.durationLabel,
                  style: const TextStyle(
                    color: RadioThemeColors.navy,
                    fontSize: 12,
                  ),
                ),
              IconButton(
                onPressed: onMoreTap,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: RadioThemeColors.navy,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchSongArtwork extends StatelessWidget {
  final RadioSong song;

  const _SearchSongArtwork({required this.song});

  @override
  Widget build(BuildContext context) {
    final imageUrl = song.imageUrl;
    if (imageUrl != null && imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _assetImage(),
      );
    }

    return _assetImage();
  }

  Widget _assetImage() {
    return Image.asset(
      song.imageAsset,
      width: 48,
      height: 48,
      fit: BoxFit.cover,
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  final RadioPlaylist playlist;
  final VoidCallback onTap;

  const _PlaylistTile({
    required this.playlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RadioThemeColors.row,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              const SizedBox(width: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _PlaylistImage(playlist: playlist),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RadioThemeColors.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      playlist.songCount,
                      style: const TextStyle(
                        color: RadioThemeColors.navy,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaylistImage extends StatelessWidget {
  final RadioPlaylist playlist;

  const _PlaylistImage({required this.playlist});

  @override
  Widget build(BuildContext context) {
    final imageUrl = playlist.imageUrl;
    if (imageUrl != null && imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _assetImage(),
      );
    }

    return _assetImage();
  }

  Widget _assetImage() {
    return Image.asset(
      playlist.imageAsset,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }
}
