import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:riot_spotify_flutter/core/models/game_status.dart';

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

    // Atualiza contador quando o ViewModel envia novo estado
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
      setState(() => _elapsedSeconds++);
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

    if (gameStatus == null || !gameStatus.isPlaying) {
      return Card(
        color: Colors.white.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 16),
              Text(
                'Não está jogando no momento',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: widget.gradientColors
                .map((c) => c.withValues(alpha: 0.3))
                .toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.championSplash != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  widget.championSplash!,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Jogando: ${gameStatus.champion}',
              style: TextStyle(
                color: widget.gradientColors.first,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Modo: ${gameStatus.gameMode}',
              style: TextStyle(
                color: widget.gradientColors.last.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text(
                'Tempo de jogo: ${_formatGameTime(_elapsedSeconds)}',
                key: ValueKey(_elapsedSeconds),
                style: TextStyle(
                  color: widget.gradientColors.last.withValues(alpha: 0.8),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
