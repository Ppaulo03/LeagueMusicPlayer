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
            ? colors.take(2).toList()
            : HomeConstants.defaultGradient;

        // Estratégia Visual:
        // Mantemos o GradientBackground como pai de tudo para garantir que o fundo
        // seja desenhado atrás da barra de título e do conteúdo.
        return GradientBackground(
          colors: gradientColors,
          child: ScaffoldPage(
            // Padding zero para deixar o gradiente encostar nas bordas
            padding: EdgeInsets.zero,

            // Header customizado (Sua HomeAppBar antiga deve ser adaptada para não usar AppBar do Material)
            header: Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
              ), // Pequeno ajuste para a barra de janela
              child: HomeAppBar(gradientColors: gradientColors),
            ),

            content: Padding(
              padding:
                  HomeConstants.screenPadding, // Padding lateral do conteúdo
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Substituímos o container manual pelo InfoBar nativo do Windows
                  if (vm.isApiKeyMissing)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: _buildApiKeyInfoBar(context),
                    ),

                  // Seção de Status do Jogo
                  GameStatusSection(gradientColors: gradientColors),

                  HomeConstants.sectionSpacing,

                  const Spacer(),

                  // Player de Música
                  MusicPlayerSection(gradientColors: gradientColors),

                  // Um pequeno padding extra no fundo para não colar na barra de tarefas
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // O componente nativo de aviso do Windows
  Widget _buildApiKeyInfoBar(BuildContext context) {
    return InfoBar(
      title: const Text('Configuração Necessária'),
      content: const Text('Sua chave API não está configurada.'),
      severity: InfoBarSeverity.warning, // Cor amarela/laranja nativa
      isLong: true, // Ocupa a largura disponível
      action: Button(
        child: const Text('Configurar'),
        onPressed: () {
          Navigator.push(
            context,
            FluentPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      onClose: () {
        // Opcional: Lógica para fechar o aviso temporariamente se quiser
      },
    );
  }
}
