import 'package:fluent_ui/fluent_ui.dart';
import 'package:league_music_player/features/home/view/widgets/music_player_widget.dart';

class MusicPlayerSection extends StatelessWidget {
  final List<Color> gradientColors;

  const MusicPlayerSection({super.key, required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return MusicPlayerWidget(gradientColors: gradientColors);
  }
}
