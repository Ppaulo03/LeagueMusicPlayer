import 'package:riot_spotify_flutter/services/apis/api_service.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:riot_spotify_flutter/core/models/game_status.dart';

class GameStatusApi extends ApiService {
  late final String url = 'game-status';

  Future<GameStatus> getGameStatus() async {
    final response = await get(url);
    if (!isOk(response)) {
      return _emptyStatus();
    }
    try {
      return GameStatus.fromJson(json.decode(response!.body));
    } catch (_) {
      return _emptyStatus();
    }
  }

  Future<Uint8List> getChampionSplash() async {
    final response = await get('$url/splash');
    if (!isOk(response)) return Uint8List(0);
    return response!.bodyBytes;
  }

  GameStatus _emptyStatus() => GameStatus(
    champion: '',
    championSkin: '0',
    gameMode: '',
    gameTime: '0',
    isPlaying: false,
    skinColors: const [],
  );
}
