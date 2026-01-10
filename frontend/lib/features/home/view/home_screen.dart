import 'package:flutter/material.dart';
import 'package:riot_spotify_flutter/features/home/view/widgets/game_status_widget.dart';
import 'package:riot_spotify_flutter/features/home/view/widgets/music_player_widget.dart';
import 'package:riot_spotify_flutter/features/home/viewmodel/home_viewmodel.dart';
import 'package:riot_spotify_flutter/features/settings/view/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _viewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final colors = _viewModel.championSplashGradient;
            final gradientColors = (colors != null && colors.isNotEmpty)
                ? colors.take(2).toList()
                : [const Color(0xFF1F1C2C), const Color(0xFF928DAB)];

            return AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Riot Spotify',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),

      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final colors = _viewModel.championSplashGradient;
          final gradientColors = (colors != null && colors.isNotEmpty)
              ? colors.take(2).toList()
              : [const Color(0xFF1F1C2C), const Color(0xFF928DAB)];

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    GameStatusWidget(
                      gameStatus: _viewModel.gameStatus,
                      championSplash: _viewModel.championSplash,
                      gradientColors: gradientColors,
                    ),
                    const SizedBox(height: 24),
                    const Spacer(),
                    MusicPlayerWidget(gradientColors: gradientColors)
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
