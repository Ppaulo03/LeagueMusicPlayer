import 'package:flutter/material.dart';
import 'package:riot_spotify_flutter/core/models/champion_config.dart';
import 'package:riot_spotify_flutter/services/apis/settings_api.dart';

/// ViewModel for managing champion configurations
class ChampionConfigViewModel extends ChangeNotifier {
  final SettingsApi _apiService;

  List<ChampionConfig> _champions = [];
  bool _isLoading = false;
  String? _error;

  ChampionConfigViewModel({SettingsApi? apiService})
      : _apiService = apiService ?? SettingsApi();

  // Getters
  List<ChampionConfig> get champions => _champions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Fetches all champion configurations from the API
  Future<void> fetchChampions() async {
    _setLoading(true);
    _clearError();

    try {
      _champions = await _apiService.getChampionConfigs();
    } catch (e) {
      _setError('Erro ao carregar campeões: $e');
      debugPrint('Error fetching champions: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Saves all champion configurations to the API
  Future<void> saveAll() async {
    try {
      await _apiService.patchChampionConfigs(_champions);
    } catch (e) {
      _setError('Erro ao salvar configurações: $e');
      debugPrint('Error saving champions: $e');
      rethrow;
    }
  }

  /// Updates a specific champion configuration
  void updateChampion(ChampionConfig updatedChampion) {
    final index = _champions.indexWhere((c) => c.name == updatedChampion.name);
    if (index != -1) {
      _champions[index] = updatedChampion;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Retry fetching champions after an error
  Future<void> retry() async {
    await fetchChampions();
  }
}
