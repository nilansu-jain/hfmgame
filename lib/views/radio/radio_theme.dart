import 'package:flutter/material.dart';

class RadioThemeColors {
  static const Color background = Color(0xFFF9F9F9);
  static const Color navy = Color(0xFF021C42);
  static const Color softText = Color(0xFF58708D);
  static const Color row = Color(0xFFFFFFFF);
}

String radioDurationLabel(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString();
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
