import 'dart:async';
import 'dart:typed_data';
import 'dart:ui'; // Necessário para FontFeature
import 'package:fluent_ui/fluent_ui.dart';
import 'package:league_music_player/core/models/game_status.dart';

class GameStatusWidget extends StatefulWidget {
  final GameStatus? gameStatus;
  final Uint8List? championSplash;
  final List<Color> gradientColors;

  const GameStatusWidget({
    super.key,
    required this.gameStatus,
    required this.championSplash,
    required this.gradientColors,
  });

  @override
  State<GameStatusWidget> createState() => _GameStatusWidgetState();
}

class _GameStatusWidgetState extends State<GameStatusWidget> {
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _syncWithGameStatus();
  }

  @override
  void didUpdateWidget(GameStatusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gameStatus?.gameTime != oldWidget.gameStatus?.gameTime ||
        widget.gameStatus?.isPlaying != oldWidget.gameStatus?.isPlaying) {
      _syncWithGameStatus();
    }
  }

  void _syncWithGameStatus() {
    _timer?.cancel();

    if (widget.gameStatus == null || !widget.gameStatus!.isPlaying) return;

    _elapsedSeconds =
        double.tryParse(widget.gameStatus!.gameTime)?.floor() ?? 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatGameTime(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return hours > 0 ? '$hours:$minutes:$secs' : '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final gameStatus = widget.gameStatus;
    final typography = FluentTheme.of(context).typography;

    // Pegamos o tamanho total da tela para calcular o espaço disponível
    final screenSize = MediaQuery.of(context).size;

    // ESTADO: NÃO JOGANDO (IDLE)
    if (gameStatus == null || !gameStatus.isPlaying) {
      return Card(
        backgroundColor: Colors.black.withValues(
          alpha: 0.3,
        ), // Fundo escuro translúcido
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: ProgressRing(strokeWidth: 2.5, activeColor: Colors.white),
            ),
            const SizedBox(width: 16),
            Text(
              'Aguardando partida...',
              style: typography.body?.copyWith(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Card(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: widget.gradientColors
                .map((c) => c.withValues(alpha: 0.4))
                .toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.championSplash != null)
              LayoutBuilder(
                builder: (context, constraints) {
                  // 1. LÓGICA DE LARGURA (Responsividade Horizontal)
                  double targetWidth;
                  if (constraints.maxWidth > 800) {
                    targetWidth = constraints.maxWidth * 0.5;
                  } else if (constraints.maxWidth > 500) {
                    targetWidth = constraints.maxWidth * 0.8;
                  } else {
                    targetWidth = constraints.maxWidth;
                  }

                  double maxAllowedHeight = screenSize.height - 450;

                  // Segurança: Nunca deixa ser menor que 150px
                  if (maxAllowedHeight < 150) maxAllowedHeight = 150;

                  return Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      width: targetWidth,

                      // Limita a altura para evitar overflow se a janela for pequena
                      constraints: BoxConstraints(maxHeight: maxAllowedHeight),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.transparent],
                              stops: [0.8, 1.0],
                            ).createShader(
                              Rect.fromLTRB(0, 0, rect.width, rect.height),
                            );
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.memory(
                            widget.championSplash!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,

                            frameBuilder:
                                (
                                  context,
                                  child,
                                  frame,
                                  wasSynchronouslyLoaded,
                                ) {
                                  if (wasSynchronouslyLoaded) return child;
                                  return AnimatedOpacity(
                                    opacity: frame == null ? 0 : 1,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOut,
                                    child: child,
                                  );
                                },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            Text(
              'Jogando: ${gameStatus.champion}',
              style: typography.title?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // Modo de Jogo
            Text(
              'Modo: ${gameStatus.gameMode}',
              style: typography.body?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  _formatGameTime(_elapsedSeconds),
                  key: ValueKey(_elapsedSeconds),
                  style: typography.bodyStrong?.copyWith(
                    color: Colors.white,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
