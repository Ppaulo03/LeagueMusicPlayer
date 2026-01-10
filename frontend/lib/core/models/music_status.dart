class MusicStatus {
  final String currentTrack;
  final String artist;
  final String albumArt;
  final bool isPlaying;

  MusicStatus({
    required this.currentTrack,
    required this.artist,
    required this.albumArt,
    required this.isPlaying,
  });

  factory MusicStatus.fromJson(Map<String, dynamic> json) {
    return MusicStatus(
      currentTrack: json['currentTrack'] ?? '',
      artist: json['artist'] ?? '',
      albumArt: json['albumArt'] ?? '',
      isPlaying: json['isPlaying'] ?? false,
    );
  }
}
