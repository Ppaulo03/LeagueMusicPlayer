import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:provider/provider.dart';

import 'package:league_music_player/bootsrap.dart';
import 'package:league_music_player/core/logging.dart';
import 'package:league_music_player/features/home/viewmodel/home_viewmodel.dart';
import 'package:league_music_player/features/home/view/home_screen.dart';
import 'package:league_music_player/features/settings/viewmodel/config_viewmodel.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

Process? backendProcess;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupLogFile();
  await Window.initialize();
  await Window.setEffect(effect: WindowEffect.mica, dark: true);

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(800, 600),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  doWhenWindowReady(() {
    appWindow.minSize = const Size(800, 600);
    appWindow.alignment = Alignment.center;
  });
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
      backendProcess = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConfigViewModel()..fetchConfig(),
      child: ChangeNotifierProvider(
        create: (context) =>
            HomeViewModel(context.read<ConfigViewModel>())..init(),

        child: FluentApp(
          title: 'League Music Player',
          theme: FluentThemeData(
            brightness: Brightness.dark,
            accentColor: Colors.blue,
          ),
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
