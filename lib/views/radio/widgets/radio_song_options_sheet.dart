import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaanap_admin_new/bloc/radio_player/radio_player_bloc.dart';
import 'package:gaanap_admin_new/views/radio/radio_theme.dart';

Future<void> showRadioSongOptionsSheet(
  BuildContext context,
  RadioSong song,
    {bool showAddToQueue = true}) {
  final bloc = context.read<RadioPlayerBloc>();

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: RadioThemeColors.row,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return BlocProvider.value(
        value: bloc,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _SheetSongArtwork(song: song),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: RadioThemeColors.navy,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: RadioThemeColors.softText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SongDetail(label: 'Movie', value: song.movie),
                _SongDetail(label: 'Year', value: song.year),
                _SongDetail(label: 'Lyricist', value: song.lyricist),
                _SongDetail(label: 'Composer', value: song.composer),
                _SongDetail(label: 'Duration', value: song.durationLabel),
                const SizedBox(height: 18),
                if(showAddToQueue)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                      onPressed: () {
                        print('[showRadioSongOptionsSheet] Add to Queue button pressed');
                        print('[showRadioSongOptionsSheet] song: ${song.title}');
                        final bloc =
                        context.read<RadioPlayerBloc>();
                        print('[showRadioSongOptionsSheet] playingPlaylistId: ${bloc.state.playingPlaylistId}');
                        print('[showRadioSongOptionsSheet] currentPlaylist.id: ${bloc.state.currentPlaylist.id}');

                        if (
                        bloc.state.playingPlaylistId !=
                        bloc.state.currentPlaylist.id

                           ){
                          print('[showRadioSongOptionsSheet] playlist IDs do NOT match');
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please select current playlist for add to queue",
                              ),
                            ),
                          );

                          return;
                        }
                        print('[showRadioSongOptionsSheet] playlist IDs match! Adding song to queue');

                        bloc.add(
                          RadioSongAddToQueueRequested(song),
                        );

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Song added to queue",
                            ),
                          ),
                        );
                      },
                    icon: const Icon(Icons.playlist_add_rounded),
                    label: const Text('Add to Queue'),
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
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SongDetail extends StatelessWidget {
  final String label;
  final String value;

  const _SongDetail({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: const TextStyle(
                color: RadioThemeColors.softText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: RadioThemeColors.navy,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetSongArtwork extends StatelessWidget {
  final RadioSong song;

  const _SheetSongArtwork({required this.song});

  @override
  Widget build(BuildContext context) {
    final imageUrl = song.imageUrl;
    if (imageUrl != null && imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 58,
        height: 58,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _assetImage(),
      );
    }

    return _assetImage();
  }

  Widget _assetImage() {
    return Image.asset(
      song.imageAsset,
      width: 58,
      height: 58,
      fit: BoxFit.cover,
    );
  }
}
