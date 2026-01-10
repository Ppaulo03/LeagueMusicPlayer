import 'package:flutter/widgets.dart';
import 'package:league_music_player/services/apis/api_service.dart';
import 'dart:convert';
import 'package:league_music_player/core/models/champion_config.dart';
import 'package:league_music_player/core/models/region_config.dart';
import 'package:league_music_player/core/models/config_model.dart';

class SettingsApi extends ApiService {
  late final String championUrl = 'champions';
  late final String regionUrl = 'regions';

  Future<List<ChampionConfig>> getChampionConfigs() async {
    final response = await get(championUrl);
    if (!isOk(response)) return [];

    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        json.decode(response!.body),
      );
      return data.entries
          .map(
            (e) => ChampionConfig.fromMap(
              e.key,
              Map<String, dynamic>.from(e.value),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> patchChampionConfigs(List<ChampionConfig> championConfig) async {
    final Map<String, dynamic> championsMap = {
      for (final champ in championConfig) champ.name: champ.toMap(),
    };
    final response = await patch(championUrl, body: championsMap);
    return isOk(response);
  }

  Future<List<RegionConfig>> getRegionConfigs() async {
    final response = await get(regionUrl);
    if (!isOk(response)) return [];

    try {
      final Map<String, dynamic> raw = Map<String, dynamic>.from(
        json.decode(response!.body),
      );
      return raw.entries
          .map((e) => RegionConfig(name: e.key, styles: e.value.toString()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> patchRegionConfigs(List<RegionConfig> regionConfig) async {
    final Map<String, String> regionMap = {
      for (final region in regionConfig) region.name: region.styles,
    };
    final response = await patch(regionUrl, body: regionMap);
    return isOk(response);
  }

  Future<List<MusicData>> getMusicData(String query) async {
    if (query.trim().isEmpty) return [];
    final response = await get('$championUrl/music?query=$query');
    if (!isOk(response)) return [];

    try {
      final List<dynamic> data = json.decode(response!.body);
      return data
          .whereType<Map<String, dynamic>>()
          .map(MusicData.fromMap)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<ConfigModel?> getConfig() async {
    debugPrint('Fetching config from backend...');
    final response = await get('configs');
    if (!isOk(response)) return null;

    try {
      final Map<String, dynamic> data = json.decode(response!.body);
      return ConfigModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<String?> updateConfig(ConfigModel config) async {
    final response = await put('configs', body: config.toJson());
    if (isOk(response)) {
      return null;
    } else {
      try {
        final Map<String, dynamic> data = json.decode(response!.body);
        return data['detail'] ?? data['error'] ?? 'Erro desconhecido';
      } catch (_) {
        return 'Falha ao atualizar configuração';
      }
    }
  }
}
