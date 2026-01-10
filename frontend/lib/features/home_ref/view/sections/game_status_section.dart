import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riot_spotify_flutter/features/home/view/widgets/game_status_widget.dart';
import 'package:riot_spotify_flutter/features/home/viewmodel/home_viewmodel.dart';

class GameStatusSection extends StatelessWidget {
  final List<Color> gradientColors;

  const GameStatusSection({super.key, required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        return GameStatusWidget(
          gameStatus: vm.gameStatus,
          championSplash: vm.championSplash,
          gradientColors: gradientColors,
        );
      },
    );
  }
}
