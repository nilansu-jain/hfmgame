import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaanap_admin_new/bloc/radio_player/radio_player_bloc.dart';
import 'package:gaanap_admin_new/views/radio/radio_player_screen.dart';
import 'package:gaanap_admin_new/views/radio/radio_theme.dart';

class RadioMiniPlayer extends StatelessWidget {
  const RadioMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
      builder: (context, state) {
        if (!state.hasSelectedSong || state.songs.isEmpty) {
          return const SizedBox.shrink();
        }

        final song =
            state.playingSong ??
                state.currentSong;

        return Container(
          height: 80,
          padding: const EdgeInsets.fromLTRB(20, 10, 14, 10),
          decoration: const BoxDecoration(
            color: RadioThemeColors.row,
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                color: Color(0x29000000),
                blurRadius: 15,
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _openPlayer(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: _SongArtwork(song: song, size: 45),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openPlayer(context),
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
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
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
              ),
              IconButton(
                onPressed: () {
                  context
                      .read<RadioPlayerBloc>()
                      .add(RadioPlayPauseRequested());
                },
                icon: Icon(
                  state.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: RadioThemeColors.navy,
                  size: 40,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPlayer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<RadioPlayerBloc>(),
          child: const RadioPlayerScreen(),
        ),
      ),
    );
  }
}

class _SongArtwork extends StatelessWidget {
  final RadioSong song;
  final double size;

  const _SongArtwork({
    required this.song,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = song.imageUrl;
    if (imageUrl != null && imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _assetImage(),
      );
    }

    return _assetImage();
  }

  Widget _assetImage() {
    return Image.asset(
      song.imageAsset,
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }
}
