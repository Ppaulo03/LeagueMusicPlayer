import 'package:flutter/material.dart';
import 'package:riot_spotify_flutter/core/models/region_config.dart';
import 'package:riot_spotify_flutter/services/apis/settings_api.dart';

/// ViewModel for managing region configurations
class RegionConfigViewModel extends ChangeNotifier {
  final SettingsApi _apiService;

  List<RegionConfig> _regions = [];
  bool _isLoading = false;
  String? _error;

  RegionConfigViewModel({SettingsApi? apiService})
      : _apiService = apiService ?? SettingsApi();

  // Getters
  List<RegionConfig> get regions => _regions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Fetches all region configurations from the API
  Future<void> fetchRegions() async {
    _setLoading(true);
    _clearError();

    try {
      _regions = await _apiService.getRegionConfigs();
    } catch (e) {
      _setError('Erro ao carregar regiões: $e');
      debugPrint('Error fetching regions: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Saves all region configurations to the API
  Future<void> saveRegions() async {
    try {
      await _apiService.patchRegionConfigs(_regions);
    } catch (e) {
      _setError('Erro ao salvar configurações: $e');
      debugPrint('Error saving regions: $e');
      rethrow;
    }
  }

  /// Updates a specific region configuration
  void updateRegion(RegionConfig updatedRegion) {
    final index = _regions.indexWhere((r) => r.name == updatedRegion.name);
    if (index != -1) {
      _regions[index] = updatedRegion;
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

  /// Retry fetching regions after an error
  Future<void> retry() async {
    await fetchRegions();
  }
}
