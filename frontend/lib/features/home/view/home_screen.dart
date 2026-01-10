import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:league_music_player/features/home/core/constants/home_constants.dart';
import 'package:league_music_player/features/home/view/components/gradient_background.dart';
import 'package:league_music_player/features/home/view/components/home_app_bar.dart';
import 'package:league_music_player/features/home/view/sections/game_status_section.dart';
import 'package:league_music_player/features/home/view/sections/music_player_section.dart';
import 'package:league_music_player/features/home/viewmodel/home_viewmodel.dart';
import 'package:league_music_player/features/settings/view/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        final colors = vm.championSplashGradient;
        final gradientColors = (colors != null && colors.isNotEmpty)
            ? colors.take(2).toList()
            : HomeConstants.defaultGradient;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: HomeAppBar(gradientColors: gradientColors),
          body: GradientBackground(
            colors: gradientColors,
            child: SafeArea(
              child: Padding(
                padding: HomeConstants.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (vm.isApiKeyMissing) _buildApiKeyWarning(context),
                    const SizedBox(height: 24),
                    GameStatusSection(gradientColors: gradientColors),
                    HomeConstants.sectionSpacing,
                    const Spacer(),
                    MusicPlayerSection(gradientColors: gradientColors),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApiKeyWarning(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chave API não configurada. Vá para as configurações para adicionar sua chave API.',
              style: TextStyle(color: Colors.orange.shade800),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            child: const Text('Configurar'),
          ),
        ],
      ),
    );
  }
}
