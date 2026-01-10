import 'package:flutter/material.dart';
import 'package:riot_spotify_flutter/features/home/view/widgets/music_player_widget.dart';

class MusicPlayerSection extends StatelessWidget {
  final List<Color> gradientColors;
  const MusicPlayerSection({super.key, required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return MusicPlayerWidget(gradientColors: gradientColors);
  }
}
