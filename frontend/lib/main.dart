import 'dart:io';
import 'package:flutter/material.dart';
import 'package:league_music_player/bootsrap.dart';
import 'package:league_music_player/core/logging.dart';
import 'package:provider/provider.dart';
import 'package:league_music_player/features/home/viewmodel/home_viewmodel.dart';
import 'package:league_music_player/features/home/view/home_screen.dart';
import 'package:league_music_player/features/settings/viewmodel/config_viewmodel.dart';

Process? backendProcess;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLogFile();
  runApp(const AppBootstrap());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _killBackend();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      _killBackend();
    }
  }

  void _killBackend() {
    if (backendProcess != null) {
      debugPrint("Matando o processo do backend...");
      backendProcess!.kill();
      backendProcess = null; // Limpa a referência
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConfigViewModel()),
        ChangeNotifierProvider(
          create: (context) =>
              HomeViewModel(context.read<ConfigViewModel>())..init(),
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
