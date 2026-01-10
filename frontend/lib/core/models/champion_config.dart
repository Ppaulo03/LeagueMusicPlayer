class MusicData {
  String name;
  String artist;
  String mbid;

  MusicData({required this.name, required this.artist, required this.mbid});
  factory MusicData.fromMap(Map<String, dynamic> map) {
    return MusicData(
      name: map['name'] ?? '',
      artist: map['artist'] ?? '',
      mbid: map['mbid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'artist': artist, 'mbid': mbid};
  }

  String asString() {
    if (name != '') {
      return "$name - $artist";
    } else {
      return "";
    }
  }
}

class ChampionConfig {
  final String name;
  final String imageUrl;
  MusicData music;
  String styles;

  ChampionConfig({
    required this.name,
    required this.imageUrl,
    required this.styles,
    required this.music,
  });

  factory ChampionConfig.fromMap(String name, Map<String, dynamic> map) {
    return ChampionConfig(
      name: name,
      imageUrl: map['splash'] ?? '',
      styles: map['estilos'] ?? '',
      music: MusicData.fromMap(map['musica'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {'estilos': styles, 'musica': music.toMap(), 'splash': imageUrl};
  }
}
