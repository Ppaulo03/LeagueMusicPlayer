import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:league_music_player/main.dart';
import 'package:league_music_player/services/backend_service.dart';
import 'package:league_music_player/core/constants/app_constants.dart';

// Variável global para o processo (se precisar fechar depois)
Process? backendProcess;

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  // Future que guarda o estado da inicialização
  late Future<int?> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  // Função que agrupa toda a lógica que estava no main()
  Future<int?> _initializeApp() async {
    try {
      // 1. Configura SSL
      final sslData = await rootBundle.load('assets/certs/cacert.pem');
      final context = SecurityContext.defaultContext;
      context.setTrustedCertificatesBytes(sslData.buffer.asUint8List());

      if (kReleaseMode) {
        backendProcess = await startBackend();
      }
      final portResult = await getBackendPort();
      debugPrint("Porta obtida do backend: $portResult");
      if (portResult != null) {
        port = portResult; // Atualiza a global
        debugPrint("Backend rodando na porta: $port");
      }

      return portResult; // Retorna null se falhou após as 100 tentativas
    } catch (e) {
      debugPrint("Erro fatal na inicialização: $e");
      return null;
    }
  }

  void _retry() {
    setState(() {
      _initFuture = _initializeApp(); // Reinicia o processo
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<int?>(
        future: _initFuture,
        builder: (context, snapshot) {
          // ESTADO 1: Carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }

          // ESTADO 2: Erro ou Porta Nula (Timeout)
          if (snapshot.hasError || snapshot.data == null) {
            return ErrorScreen(onRetry: _retry);
          }

          // ESTADO 3: Sucesso -> Vai para o App Real
          return const MyApp();
        },
      ),
    );
  }
}

// --- TELA DE LOADING ---
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Iniciando servidor...", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// --- TELA DE ERRO ---
class ErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorScreen({required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                "Não foi possível conectar ao servidor.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "O tempo limite foi excedido ou ocorreu um erro interno.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text("Tentar Novamente"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
