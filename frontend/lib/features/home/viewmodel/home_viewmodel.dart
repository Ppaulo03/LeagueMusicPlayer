import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:league_music_player/core/models/game_status.dart';
import 'package:league_music_player/services/apis/game_status_api.dart';
import 'package:league_music_player/services/apis/settings_api.dart';
import 'package:league_music_player/features/settings/viewmodel/config_viewmodel.dart';

class HomeViewModel extends ChangeNotifier {
  final _apiService = GameStatusApi();
  final _settingsApi = SettingsApi();
  final ConfigViewModel _configViewModel;
  Timer? _refreshTimer;

  GameStatus? _gameStatus;
  Map<String, dynamic>? _currentTrack;
  Uint8List? _championSplash;
  bool _isApiKeyMissing = false;

  HomeViewModel(this._configViewModel) {
    debugPrint("HomeViewModel initialized");
    _configViewModel.addListener(_onConfigChanged);
  }

  GameStatus? get gameStatus => _gameStatus;
  Map<String, dynamic>? get currentTrack => _currentTrack;
  Uint8List? get championSplash => _championSplash;
  bool get isApiKeyMissing => _isApiKeyMissing;
  List<Color>? get championSplashGradient {
    if (_gameStatus?.skinColors == null || _championSplash == null) return null;
    return _gameStatus!.skinColors.map((hex) => hexToColor(hex)).toList();
  }

  Future<void> init() async {
    await _checkApiKey();
    await _fetchData();
    _startPeriodicFetch();
  }

  Future<void> _checkApiKey() async {
    try {
      debugPrint("Checking API key in config...");
      final config = await _settingsApi.getConfig();
      _isApiKeyMissing = config?.apiKey == null || config!.apiKey!.isEmpty;
      debugPrint('API Key missing: $_isApiKeyMissing');
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking API key: $e');
      _isApiKeyMissing = true; // Assume missing if error
      notifyListeners();
    }
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> _fetchData() async {
    try {
      final status = await _apiService.getGameStatus();
      if (status.isPlaying) {
        if (_championSplash == null ||
            status.champion != _gameStatus?.champion ||
            status.championSkin != _gameStatus?.championSkin) {
          final splash = await _apiService.getChampionSplash();
          if (splash.isNotEmpty) {
            _championSplash = splash;
          }
        }
      } else {
        _championSplash = null;
      }

      _gameStatus = status;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  void _startPeriodicFetch() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _fetchData(),
    );
  }

  void _onConfigChanged() {
    debugPrint("Config changed, checking API key...");
    _checkApiKey();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _configViewModel.removeListener(_onConfigChanged);
    super.dispose();
  }
}
