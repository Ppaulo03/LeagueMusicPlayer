import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:riot_spotify_flutter/core/constants/app_constants.dart';
import 'package:riot_spotify_flutter/core/models/config_model.dart';

final tempDir = Directory.systemTemp.path;
final portFile = File('$tempDir/backend_port.json');

Future<Process?> startBackend() async {
  try {
    if (await portFile.exists()) {
      await portFile.delete();
    }

    final exePath = p.join(Directory.current.path, 'backend', 'app.exe');
    final process = await Process.start('cmd', [
      '/k',
      exePath,
    ], runInShell: true);

    process.stdout.transform(SystemEncoding().decoder).listen((data) {
      debugPrint('[stdout] $data');
    });

    process.stderr.transform(SystemEncoding().decoder).listen((data) {
      debugPrint('[stderr] $data');
    });
    return process;
  } catch (e) {
    return null;
  }
}

Future<int?> getBackendPort() async {
  for (int i = 0; i < 100; i++) {
    if (await portFile.exists()) {
      final content = await portFile.readAsString();
      final data = json.decode(content);
      return data['port'];
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }
  return null;
}

Future<bool> testPing() async {
  if (port == 0) return false;
  try {
    final uri = Uri.parse('http://127.0.0.1:$port/ping');
    final res = await http.get(uri).timeout(const Duration(seconds: 3));
    return res.statusCode >= 200 && res.statusCode < 300;
  } catch (_) {
    return false;
  }
}

Future<ConfigModel?> getConfigs() async {
  if (port == 0) return null;
  try {
    final uri = Uri.parse('http://127.0.0.1:$port/configs');
    final res = await http.get(uri).timeout(const Duration(seconds: 3));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = json.decode(res.body);
      return ConfigModel.fromJson(data);
    }
  } catch (_) {}
  return null;
}

Future<String?> updateConfigs(ConfigModel config) async {
  if (port == 0) return 'Backend not running';
  try {
    final uri = Uri.parse('http://127.0.0.1:$port/configs');
    final res = await http
        .put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(config.toJson()),
        )
        .timeout(const Duration(seconds: 3));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return null; // Success
    } else {
      final data = json.decode(res.body);
      return data['error'] ?? 'Unknown error';
    }
  } catch (e) {
    return 'Network error: $e';
  }
}
