import 'package:league_music_player/services/apis/api_service.dart';
import 'dart:convert';
import 'package:league_music_player/core/models/config_model.dart';

class SettingsApi extends ApiService {
  late final String championUrl = 'champions';
  late final String regionUrl = 'regions';

  Future<ConfigModel?> getConfig() async {
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
