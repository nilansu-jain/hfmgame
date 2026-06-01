import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AirPlayRoutePicker extends StatelessWidget {
  const AirPlayRoutePicker({super.key});

  static const _viewType = 'hfmgame/airplay_route_picker';

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return const SizedBox.shrink();
    }

    return const SizedBox(
      width: 44,
      height: 44,
      child: UiKitView(
        viewType: _viewType,
        creationParamsCodec: StandardMessageCodec(),
      ),
    );
  }
}
