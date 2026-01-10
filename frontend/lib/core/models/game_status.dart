class GameStatus {
  final String champion;
  final String championSkin;
  final String gameMode;
  final String gameTime;
  final bool isPlaying;
  final List<String> skinColors;

  GameStatus({
    required this.champion,
    required this.championSkin,
    required this.gameMode,
    required this.gameTime,
    required this.isPlaying,
    required this.skinColors,
  });

  factory GameStatus.fromJson(Map<String, dynamic> json) {
    return GameStatus(
      champion: json['championName'] ?? '',
      championSkin: json['championSkin'] ?? '0',
      gameMode: json['gameMode'] ?? '',
      gameTime: json['gameTime']?.toString() ?? '',
      isPlaying: json['isPlaying'] ?? false,
      skinColors: List<String>.from(json['championPalette']),
    );
  }
}
