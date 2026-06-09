import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaanap_admin_new/bloc/radio_player/radio_player_bloc.dart';
import 'package:gaanap_admin_new/views/radio/radio_player_screen.dart';
import 'package:gaanap_admin_new/views/radio/radio_theme.dart';
import 'package:gaanap_admin_new/views/radio/widgets/radio_mini_player.dart';
import 'package:gaanap_admin_new/views/radio/widgets/radio_song_options_sheet.dart';

class RadioPlaylistSongsScreen extends StatelessWidget {
  const RadioPlaylistSongsScreen({super.key});

  final List<RadioSong> queueSongs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RadioThemeColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _SongsHeader(),
            const _PlaylistSummary(),
            const _SearchBox(),
            const _ShuffleButton(),
            Expanded(
              child: BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
                builder: (context, state) {
                  if (state.songsStatus == RadioSongsStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: RadioThemeColors.navy,
                      ),
                    );
                  }

                  if (state.songsStatus == RadioSongsStatus.error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Text(
                          state.songsMessage.isEmpty
                              ? 'Unable to load songs'
                              : state.songsMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: RadioThemeColors.navy,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }

                  final songs = state.filteredSongs;
                  if (songs.isEmpty) {
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
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                    itemCount: songs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return _SongTile(
                        song: song,
                        onTap: () {
                          final originalIndex = state.songs.indexOf(song);
                          context
                              .read<RadioPlayerBloc>()
                              .add(RadioSongSelected(originalIndex));
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
                        onMoreTap: () => showRadioSongOptionsSheet(
                          context,
                          song,
                        ),
                      );
                    },
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

class _ShuffleButton extends StatelessWidget {
  const _ShuffleButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
      builder: (context, state) {
        if (state.songsStatus != RadioSongsStatus.completed ||
            state.songs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<RadioPlayerBloc>().add(RadioShuffleRequested());
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
              icon: const Icon(Icons.shuffle_rounded),
              label: const Text('Shuffle Songs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: RadioThemeColors.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SongsHeader extends StatelessWidget {
  const _SongsHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: RadioThemeColors.navy,
              size: 36,
            ),
          ),
          const Expanded(
            child: Text(
              'Playlists',
              style: TextStyle(
                color: RadioThemeColors.navy,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistSummary extends StatelessWidget {
  const _PlaylistSummary();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
      builder: (context, state) {
        final playlist = state.currentPlaylist;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _PlaylistSummaryImage(playlist: playlist),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playlist.updatedAt,
                      style: const TextStyle(
                        color: RadioThemeColors.navy,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playlist.songCount,
                      style: const TextStyle(
                        color: RadioThemeColors.navy,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlaylistSummaryImage extends StatelessWidget {
  final RadioPlaylist playlist;

  const _PlaylistSummaryImage({required this.playlist});

  @override
  Widget build(BuildContext context) {
    final imageUrl = playlist.imageUrl;
    if (imageUrl != null && imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _assetImage(),
      );
    }

    return _assetImage();
  }

  Widget _assetImage() {
    return Image.asset(
      playlist.imageAsset,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: RadioThemeColors.row,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (value) {
          context.read<RadioPlayerBloc>().add(RadioSongSearchChanged(value));
        },
        style: const TextStyle(
          color: RadioThemeColors.navy,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          icon: Icon(
            Icons.search_rounded,
            color: RadioThemeColors.navy,
            size: 22,
          ),
          hintText: 'Search Playlist Song',
          hintStyle: TextStyle(
            color: RadioThemeColors.softText,
            fontSize: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  final RadioSong song;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const _SongTile({
    required this.song,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    // debugPrint("Song :: ${song.toString()}");
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
                child: _SongArtwork(song: song),
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

class _SongArtwork extends StatelessWidget {
  final RadioSong song;

  const _SongArtwork({required this.song});

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
