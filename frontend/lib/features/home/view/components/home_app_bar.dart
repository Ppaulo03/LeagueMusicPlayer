import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:league_music_player/core/widgets/window_buttons.dart';
import 'package:league_music_player/features/home/core/constants/home_constants.dart';
import 'package:league_music_player/features/settings/view/settings_screen.dart';
import 'package:league_music_player/features/settings/viewmodel/config_viewmodel.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class HomeAppBar extends StatelessWidget {
  final List<Color> gradientColors;

  const HomeAppBar({super.key, required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          Positioned.fill(child: MoveWindow()),
          // --- 1. ESQUERDA: Botão de Configurações ---
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Tooltip(
                message: 'Configurações',
                child: IconButton(
                  icon: const Icon(
                    FluentIcons.settings,
                    size: 20,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      FluentPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) => ConfigViewModel(),
                          child: const SettingsScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // --- 2. CENTRO: Título ---
          Align(
            alignment: Alignment.center,
            child: Text(
              HomeConstants.appBarTitle.toUpperCase(),
              style: FluentTheme.of(context).typography.subtitle?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
            ),
          ),

          // --- 3. DIREITA: Controles da Janela (Fechar, Maximizar) ---
          const Positioned(right: 0, top: 0, child: WindowButtons()),
        ],
      ),
    );
  }
}
