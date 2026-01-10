import 'package:flutter/material.dart';
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
    return ChangeNotifierProvider(
      create: (_) => MusicPlayerViewModel(),
      child: Consumer<MusicPlayerViewModel>(
        builder: (context, vm, _) {
          final colors =
              widget.gradientColors ??
              [const Color(0xFF1F1C2C), const Color(0xFF928DAB)];

          return MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.first.withValues(alpha: 0.9),
                    colors.last.withValues(alpha: 0.9),
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
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                    ),
                    child: Slider(
                      value: vm.position.inSeconds.toDouble(),
                      max: vm.duration.inSeconds.toDouble().clamp(
                        1,
                        double.infinity,
                      ),
                      onChanged: (v) {
                        vm.seek(Duration(seconds: v.toInt()));
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white24,
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${vm.position.inMinutes}:${(vm.position.inSeconds % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "${vm.duration.inMinutes}:${(vm.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: vm.isLoading
                              ? Row(
                                  key: const ValueKey('loading'),
                                  children: [
                                    const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white70,
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
                              : Text(
                                  vm.currentFilename ?? 'Nenhuma música',
                                  key: ValueKey(vm.currentFilename ?? 'none'),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            color: Colors.white,
                            iconSize: 28,
                            onPressed: vm.isLoading
                                ? null
                                : () => vm.previousTrack(),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                            child: IconButton(
                              icon: Icon(
                                vm.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                              onPressed: vm.isLoading
                                  ? null
                                  : () => vm.togglePlayPause(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            color: Colors.white,
                            iconSize: 28,
                            onPressed: vm.isLoading
                                ? null
                                : () => vm.nextTrack(),
                          ),
                        ],
                      ),

                      const SizedBox(width: 12),

                      // 🎚 Controle de volume com hover
                      Expanded(
                        child: AnimatedOpacity(
                          opacity: _hovering ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => vm.toggleMute(),
                                child: Icon(
                                  vm.volume == 0
                                      ? Icons.volume_off
                                      : vm.volume < 0.5
                                      ? Icons.volume_down
                                      : Icons.volume_up,
                                  color: Colors.white70,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 3,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                  ),
                                  child: Slider(
                                    value: vm.volume,
                                    onChanged: (v) => vm.setVolume(v),
                                    min: 0,
                                    max: 1,
                                    activeColor: Colors.white,
                                    inactiveColor: Colors.white24,
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
