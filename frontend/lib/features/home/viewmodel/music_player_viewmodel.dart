import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:league_music_player/services/apis/music_player_api.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicPlayerViewModel extends ChangeNotifier {
  final _musicPlayerApi = MusicPlayerApi();
  final _audioPlayer = AudioPlayer();

  Uint8List? _currentBytes;
  String? _currentFilename;
  bool _isLoading = false;
  bool _isPlaying = false;
  double _volume = 0.3;
  double _lastVolume = 0.3;

  Duration _position = Duration.zero;
  Duration _duration = Duration(minutes: 3);

  Uint8List? get currentBytes => _currentBytes;
  String? get currentFilename => _currentFilename;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  Duration get position => _position;
  Duration get duration => _duration;

  MusicPlayerViewModel() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    _audioPlayer.onDurationChanged.listen((d) {
      _duration = d;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((p) {
      _position = p;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _position = _duration;
      nextTrack();
    });

    _audioPlayer.setVolume(_volume);
    final response = await _tryGetTrack(() => _musicPlayerApi.next());
    await _handleTrackResponse(response);
  }

  void setPosition(Duration newPosition) {
    _position = newPosition;
    notifyListeners();
  }

  void setDuration(Duration newDuration) {
    _duration = newDuration;
    notifyListeners();
  }

  Future<void> seek(Duration newPosition) async {
    await _audioPlayer.seek(newPosition);
    _position = newPosition;
    notifyListeners();
  }

  Future<void> toggleMute() async {
    if (_volume > 0) {
      _lastVolume = _volume;
      await setVolume(0);
    } else {
      await setVolume(_lastVolume);
    }
  }

  Future<void> setVolume(double value) async {
    _volume = value;
    await _audioPlayer.setVolume(value);
    notifyListeners();
  }

  Future<void> nextTrack() async {
    _isLoading = true;
    notifyListeners();

    final response = await _tryGetTrack(() => _musicPlayerApi.next());
    await _handleTrackResponse(response);
  }

  Future<void> previousTrack() async {
    _isLoading = true;
    notifyListeners();

    final response = await _tryGetTrack(() => _musicPlayerApi.previous());
    await _handleTrackResponse(response);
  }

  Future<Map<String, dynamic>?> _tryGetTrack(
    Future<Map<String, dynamic>?> Function() request,
  ) async {
    for (var i = 0; i < 3; i++) {
      final res = await request();
      if (res != null) return res;
      await Future.delayed(const Duration(seconds: 1));
    }
    return null;
  }

  Future<void> _handleTrackResponse(Map<String, dynamic>? response) async {
    while (response == null) {
      response = await _tryGetTrack(() => _musicPlayerApi.next());
    }

    _currentFilename = response['filename'];
    _currentBytes = response['bytes'];
    _isLoading = false;

    await _audioPlayer.stop();
    await _audioPlayer.play(BytesSource(_currentBytes!));
    _isPlaying = true;

    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    } else {
      await _audioPlayer.resume();
      _isPlaying = true;
    }
    notifyListeners();
  }

  void disposePlayer() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
