import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:league_music_player/core/constants/app_constants.dart';
import 'package:league_music_player/features/home/viewmodel/home_viewmodel.dart';
import 'package:league_music_player/services/backend_service.dart';
import 'package:league_music_player/features/home/view/home_screen.dart';
import 'package:league_music_player/features/settings/viewmodel/config_viewmodel.dart';

Process? backendProcess;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sslData = await rootBundle.load('assets/certs/cacert.pem');
  final context = SecurityContext.defaultContext;
  context.setTrustedCertificatesBytes(sslData.buffer.asUint8List());
  if (kReleaseMode) {
    backendProcess = await startBackend();
  }
  port = (await getBackendPort())!;
  await Future.delayed(const Duration(seconds: 1));
  runApp(const MyApp());
  if (kReleaseMode) {
    ProcessSignal.sigint.watch().listen((_) {
      backendProcess?.kill();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConfigViewModel()),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(
            context.read<ConfigViewModel>(), // Pega a instância criada acima
          )..init(),
        ),
      ],
      child: MaterialApp(
        title: 'League Music Player',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}
