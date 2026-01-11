import 'dart:math';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:league_music_player/features/home/viewmodel/music_player_viewmodel.dart';

class MusicPlayerWidget extends StatefulWidget {
  final List<Color>? gradientColors;

  const MusicPlayerWidget({super.key, this.gradientColors});

  @override
  State<MusicPlayerWidget> createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    // Definindo as cores padrão caso venham nulas
    final defaultColors = [const Color(0xFF1F1C2C), const Color(0xFF928DAB)];
    final currentColors = widget.gradientColors ?? defaultColors;

    return ChangeNotifierProvider(
      create: (_) => MusicPlayerViewModel(),
      child: Consumer<MusicPlayerViewModel>(
        builder: (context, vm, _) {
          return MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    currentColors.first.withValues(alpha: 0.9),
                    currentColors.last.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // -----------------------------------------------------------
                  // BARRA DE PROGRESSO (SLIDER)
                  // -----------------------------------------------------------
                  Slider(
                    value: vm.position.inSeconds.toDouble(),
                    max: max(1.0, vm.duration.inSeconds.toDouble()),
                    onChanged: (v) {
                      vm.seek(Duration(seconds: v.toInt()));
                    },
                    style: SliderThemeData(
                      activeColor: WidgetStateProperty.all(Colors.white),
                      inactiveColor: WidgetStateProperty.all(
                        Colors.white.withValues(alpha: 0.2),
                      ),
                      thumbColor: WidgetStateProperty.all(Colors.white),
                      margin: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // -----------------------------------------------------------
                  // TIMESTAMPS
                  // -----------------------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${vm.position.inMinutes}:${(vm.position.inSeconds % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        "${vm.duration.inMinutes}:${(vm.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // -----------------------------------------------------------
                  // LINHA DE CONTROLES INFERIOR
                  // -----------------------------------------------------------
                  Row(
                    children: [
                      // PARTE ESQUERDA: Loading ou Título da Música
                      Expanded(
                        flex: 4,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: vm.isLoading
                              ? Row(
                                  key: const ValueKey('loading'),
                                  children: [
                                    const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: ProgressRing(
                                        strokeWidth: 2,
                                        activeColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Carregando...',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                )
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    vm.currentFilename ??
                                        'Aguardando seleção...',
                                    key: ValueKey(vm.currentFilename ?? 'none'),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      // PARTE CENTRAL: Botões de Play/Pause
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              FluentIcons.previous,
                              color: Colors.white,
                            ),
                            onPressed: vm.isLoading
                                ? null
                                : () => vm.previousTrack(),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                vm.isPlaying
                                    ? FluentIcons.pause
                                    : FluentIcons.play,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: vm.isLoading
                                  ? null
                                  : () => vm.togglePlayPause(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              FluentIcons.next,
                              color: Colors.white,
                            ),
                            onPressed: vm.isLoading
                                ? null
                                : () => vm.nextTrack(),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // PARTE DIREITA: Volume
                      Expanded(
                        flex: 4,
                        child: AnimatedOpacity(
                          opacity: _hovering ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () => vm.toggleMute(),
                                child: Icon(
                                  vm.volume == 0
                                      ? FluentIcons.volume0
                                      : vm.volume < 0.5
                                      ? FluentIcons.volume1
                                      : FluentIcons.volume3,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 18,
                                ),
                              ),
                              Flexible(
                                child: Slider(
                                  value: vm.volume,
                                  onChanged: (v) => vm.setVolume(v),
                                  max: 1.0,
                                  style: SliderThemeData(
                                    thumbColor: WidgetStateProperty.all(
                                      Colors.white,
                                    ),
                                    activeColor: WidgetStateProperty.all(
                                      Colors.white,
                                    ),
                                    inactiveColor: WidgetStateProperty.all(
                                      Colors.white.withValues(alpha: 0.2),
                                    ),
                                    margin: const EdgeInsets.all(0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
