import 'dart:async';
import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_theme/system_theme.dart';

import 'package:league_music_player/main.dart';
import 'package:league_music_player/services/backend_service.dart';
import 'package:league_music_player/core/constants/app_constants.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<int?> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  Future<int?> _initializeApp() async {
    try {
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(
        size: Size(1000, 700),
        center: true,
        titleBarStyle: TitleBarStyle.hidden,
        skipTaskbar: false,
        backgroundColor: Colors.transparent,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.setMinimumSize(const Size(800, 600));
        await windowManager.show();
        await windowManager.focus();
      });

      final sslData = await rootBundle.load('assets/certs/cacert.pem');
      final context = SecurityContext.defaultContext;
      context.setTrustedCertificatesBytes(sslData.buffer.asUint8List());

      if (kReleaseMode) {
        backendProcess = await startBackend();
      }

      final portResult = await getBackendPort();
      debugPrint("Porta obtida do backend: $portResult");

      if (portResult != null) {
        port = portResult;
      }

      return portResult;
    } catch (e) {
      debugPrint("Erro fatal na inicialização: $e");
      return null;
    }
  }

  void _retry() {
    setState(() {
      _initFuture = _initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'League Music Player',
      themeMode: ThemeMode.dark,
      theme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        visualDensity: VisualDensity.standard,
        fontFamily: 'Segoe UI',
      ),
      home: NavigationView(
        content: FutureBuilder<int?>(
          future: _initFuture,
          builder: (context, snapshot) {
            // ESTADO 1: Carregando
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }

            // ESTADO 2: Erro ou Timeout
            if (snapshot.hasError || snapshot.data == null) {
              return ErrorScreen(onRetry: _retry);
            }

            // ESTADO 3: Sucesso
            return const MyApp();
          },
        ),
      ),
    );
  }
}

// --- TELA DE LOADING (MODERNA) ---
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: ScaffoldPage(
        content: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 50,
                height: 50,
                child: ProgressRing(strokeWidth: 4.5),
              ),
              const SizedBox(height: 20),
              Text(
                "Iniciando Engine...",
                style: FluentTheme.of(context).typography.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- TELA DE ERRO (MODERNA) ---
class ErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorScreen({required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: ScaffoldPage(
        content: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FluentIcons.error, color: Colors.red, size: 48),
                const SizedBox(height: 20),
                Text(
                  "Falha na conexão",
                  style: FluentTheme.of(context).typography.title,
                ),
                const SizedBox(height: 10),
                Text(
                  "Não conseguimos iniciar o serviço local. Verifique se há bloqueios de firewall.",
                  textAlign: TextAlign.center,
                  style: FluentTheme.of(context).typography.body,
                ),
                const SizedBox(height: 30),
                FilledButton(
                  onPressed: onRetry,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text("Tentar Novamente"),
                  ),
                ),

                const SizedBox(height: 10),
                HyperlinkButton(
                  child: const Text("Fechar Aplicação"),
                  onPressed: () => exit(0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
