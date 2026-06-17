import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaanap_admin_new/bloc/radio_player/radio_player_bloc.dart';
import 'package:gaanap_admin_new/res/color/colors.dart';
import 'package:gaanap_admin_new/res/images/images.dart';
import 'package:gaanap_admin_new/views/radio/radio_theme.dart';
import 'package:gaanap_admin_new/views/radio/widgets/airplay_route_picker.dart';

class RadioPlayerScreen extends StatefulWidget {
  const RadioPlayerScreen({super.key});

  @override
  State<RadioPlayerScreen> createState() => _RadioPlayerScreenState();
}

class _RadioPlayerScreenState extends State<RadioPlayerScreen> {
  bool _isSeeking = false;
  Duration _seekPosition = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return
      BlocListener<RadioPlayerBloc,RadioPlayerState>(
        listener: (context,state){
          if(Navigator.canPop(context))
        Navigator.pop(context);
      },
        listenWhen: (previous,current) =>
        previous.isSearchPlayback && !current.isSearchPlayback,
      child:       Scaffold(
        backgroundColor: RadioThemeColors.background,
        body: SafeArea(
          child: BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
            builder: (context, state) {
              final song =
              state.playingSong ??
                  state.currentSong;
              final maxMilliseconds = state.duration.inMilliseconds == 0
                  ? 1.0
                  : state.duration.inMilliseconds.toDouble();
              final displayPosition = _isSeeking ? _seekPosition : state.position;
              final currentMilliseconds = displayPosition.inMilliseconds
                  .clamp(0, maxMilliseconds.toInt());
              final canSeek =
                  state.hasSelectedSong && state.duration > Duration.zero;

              return Column(
                children: [
                  const _PlayerHeader(),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: _PlayerArtwork(song: song),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        Text(
                          song.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: RadioThemeColors.navy,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SongMeta(label: 'Singer', value: song.artist),
                        _SongMeta(label: 'Lyricist', value: song.lyricist),
                        _SongMeta(label: 'Composer', value: song.composer),
                        _SongMeta(label: 'Movie', value: song.movie),
                        _SongMeta(label: 'Year', value: song.year),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape:
                            const RoundSliderOverlayShape(overlayRadius: 4),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                            activeTrackColor: AppColors.primaryColor,
                            inactiveTrackColor: const Color(0xFFD8DDE4),
                            thumbColor: AppColors.white,
                          ),
                          child: Slider(
                            min: 0,
                            max: maxMilliseconds,
                            value: currentMilliseconds.toDouble(),
                            onChangeStart: canSeek
                                ? (value) {
                              setState(() {
                                _isSeeking = true;
                                _seekPosition = Duration(
                                  milliseconds: value.round(),
                                );
                              });
                            }
                                : null,
                            onChanged: canSeek
                                ? (value) {
                              setState(() {
                                _isSeeking = true;
                                _seekPosition = Duration(
                                  milliseconds: value.round(),
                                );
                              });
                            }
                                : null,
                            onChangeEnd: canSeek
                                ? (value) {
                              final position = Duration(
                                milliseconds: value.round(),
                              );
                              setState(() {
                                _isSeeking = false;
                                _seekPosition = position;
                              });
                              context.read<RadioPlayerBloc>().add(
                                RadioSeekRequested(position),
                              );
                            }
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                radioDurationLabel(displayPosition),
                                style: const TextStyle(
                                  color: RadioThemeColors.navy,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                state.duration == Duration.zero
                                    ? song.durationLabel
                                    : radioDurationLabel(state.duration),
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
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          context
                              .read<RadioPlayerBloc>()
                              .add(RadioPreviousRequested());
                        },
                        icon: const Icon(
                          Icons.skip_previous_rounded,
                          color: RadioThemeColors.navy,
                          size: 42,
                        ),
                      ),
                      const SizedBox(width: 24),
                      InkWell(
                        onTap: () {
                          context
                              .read<RadioPlayerBloc>()
                              .add(RadioPlayPauseRequested());
                        },
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: RadioThemeColors.navy,
                            image: DecorationImage(
                                image: AssetImage(AppImages.playBackground)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            state.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: () {
                          context
                              .read<RadioPlayerBloc>()
                              .add(RadioNextRequested());
                        },
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          color: RadioThemeColors.navy,
                          size: 42,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
      );
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader();

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
              '1 Star HFM',
              style: TextStyle(
                color: RadioThemeColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            width: 60,
            child: Center(child: AirPlayRoutePicker()),
          ),
        ],
      ),
    );
  }
}

class _PlayerArtwork extends StatelessWidget {
  final RadioSong song;

  const _PlayerArtwork({required this.song});

  @override
  Widget build(BuildContext context) {
    final imageUrl = song.imageUrl;
    if (imageUrl != null && imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 280,
        height: 280,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _assetImage(),
      );
    }

    return _assetImage();
  }

  Widget _assetImage() {
    return Image.asset(
      song.imageAsset,
      width: 280,
      height: 280,
      fit: BoxFit.cover,
    );
  }
}

class _SongMeta extends StatelessWidget {
  final String label;
  final String value;

  const _SongMeta({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label : $value',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: RadioThemeColors.navy,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
