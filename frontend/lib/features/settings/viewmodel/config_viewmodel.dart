import 'package:flutter/material.dart';
import 'package:league_music_player/core/models/config_model.dart';
import 'package:league_music_player/services/apis/settings_api.dart';

class ConfigViewModel extends ChangeNotifier {
  final SettingsApi _apiService;

  ConfigModel? _config;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  ConfigViewModel({SettingsApi? apiService})
    : _apiService = apiService ?? SettingsApi();

  ConfigModel? get config => _config;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  String? get successMessage => _successMessage;
  bool get hasSuccess => _successMessage != null;

  Future<void> fetchConfig() async {
    _setLoading(true);
    _clearMessages();

    try {
      _config = await _apiService.getConfig();
    } catch (e) {
      _setError('Erro ao carregar configurações: $e');
      debugPrint('Error fetching config: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateConfig(ConfigModel newConfig) async {
    _setLoading(true);
    _clearMessages();

    try {
      final error = await _apiService.updateConfig(newConfig);
      if (error != null) {
        _setError(error);
      } else {
        _config = newConfig;
        _setSuccess('Configurações salvas com sucesso!');
      }
    } catch (e) {
      _setError('Erro ao salvar configurações: $e');
      debugPrint('Error updating config: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _error = null;
    debugPrint('Config update success: $message');
    notifyListeners();
  }

  void _clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
