import 'package:fluent_ui/fluent_ui.dart'; // Troca o material pelo fluent_ui
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
            ? colors.take(3).toList()
            : HomeConstants.defaultGradient;

        return GradientBackground(
          colors: gradientColors,
          child: ScaffoldPage(
            padding: EdgeInsets.zero,
            header: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: HomeAppBar(gradientColors: gradientColors),
            ),

            content: Padding(
              padding: HomeConstants.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (vm.isApiKeyMissing)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: _buildApiKeyInfoBar(context),
                    ),

                  GameStatusSection(gradientColors: gradientColors),
                  HomeConstants.sectionSpacing,
                  const Spacer(),
                  MusicPlayerSection(gradientColors: gradientColors),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApiKeyInfoBar(BuildContext context) {
    return InfoBar(
      title: const Text('Configuração Necessária'),
      content: const Text('Sua chave API não está configurada.'),
      severity: InfoBarSeverity.warning,
      isLong: true,
      action: Button(
        child: const Text('Configurar'),
        onPressed: () {
          Navigator.push(
            context,
            FluentPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      onClose: () {},
    );
  }
}
