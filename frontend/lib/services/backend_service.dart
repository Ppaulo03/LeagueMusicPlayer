import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:league_music_player/core/constants/app_constants.dart';
import 'package:league_music_player/core/models/config_model.dart';

final tempDir = Directory.systemTemp.path;
final portFile = File('$tempDir/backend_port.json');

Future<Process?> startBackend() async {
  try {
    if (await portFile.exists()) {
      await portFile.delete();
    }

    String exeDir = p.join(p.dirname(Platform.resolvedExecutable), 'backend');
    final exePath = p.join(exeDir, 'app.exe');

    debugPrint('Iniciando backend em: $exePath');
    final process = await Process.start(
      exePath,
      [],
      runInShell: false,
      mode: ProcessStartMode.normal,
    );
    process.stdout.transform(SystemEncoding().decoder).listen((data) {
      debugPrint('[Backend OUT] $data');
    });

    process.stderr.transform(SystemEncoding().decoder).listen((data) {
      debugPrint('[Backend ERR] $data');
    });

    return process;
  } catch (e, stackTrace) {
    debugPrint('Erro ao iniciar backend: $e');
    debugPrint(stackTrace.toString());
    return null;
  }
}

Future<int?> getBackendPort() async {
  // Tenta por aproximadamente 20 segundos (100 * 200ms)
  for (int i = 0; i < 100; i++) {
    try {
      if (await portFile.exists()) {
        final content = await portFile.readAsString();
        final data = json.decode(content);
        final int? candidatePort = data['port'];
        if (candidatePort != null) {
          final isReady = await testPing(candidatePort);
          if (isReady) {
            return candidatePort;
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao tentar ler a porta: $e');
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }

  return null; // Timeout
}

Future<bool> testPing(int port) async {
  try {
    final uri = Uri.parse('http://127.0.0.1:$port/ping');
    final res = await http.get(uri).timeout(const Duration(milliseconds: 500));
    debugPrint('Ping status code: ${res.statusCode}');
    return res.statusCode >= 200 && res.statusCode < 300;
  } catch (e) {
    debugPrint('Ping error: $e');
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
