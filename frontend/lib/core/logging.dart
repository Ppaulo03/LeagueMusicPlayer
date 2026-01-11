import 'dart:io';
import 'package:flutter/material.dart';

final ValueNotifier<List<String>> appLogs = ValueNotifier([]);
File? _logFile;

Future<void> setupLogFile() async {
  try {
    // 1. Pega o caminho exato do executável (ex: C:\Games\MeuApp\meu_app.exe)
    final exePath = Platform.resolvedExecutable;

    // 2. Pega a pasta onde ele está (ex: C:\Games\MeuApp)
    final exeDir = File(exePath).parent;

    // 3. Define a pasta 'logs' dentro do diretório do executável
    final logDir = Directory('${exeDir.path}/logs');

    // 4. Cria a pasta 'logs' se ela não existir
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    // 5. Define o arquivo de log com a data atual
    final dateStr = DateTime.now().toString().split(' ').first; // 2024-01-10
    _logFile = File('${logDir.path}/log_$dateStr.txt');

    await _logFile!.writeAsString(
      "\n--- INÍCIO DO LOG (${DateTime.now()}) ---\n",
      mode: FileMode.append,
    );
  } catch (e) {
    debugPrint("Erro crítico ao criar log: $e");
  }
}

void addLog(String message) {
  final timestamp = DateTime.now().toString().split(' ').last.split('.').first;
  final logLine = "[$timestamp] $message";
  _logFile?.writeAsString("$logLine\n", mode: FileMode.append, flush: true);
}
