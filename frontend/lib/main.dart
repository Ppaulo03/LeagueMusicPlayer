import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riot_spotify_flutter/core/constants/app_constants.dart';
import 'package:riot_spotify_flutter/features/home/viewmodel/home_viewmodel.dart';
import 'package:riot_spotify_flutter/services/backend_service.dart';
import 'package:riot_spotify_flutter/features/home/view/home_screen.dart';
import 'package:riot_spotify_flutter/features/settings/viewmodel/config_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sslData = await rootBundle.load('assets/certs/cacert.pem');
  final context = SecurityContext.defaultContext;
  context.setTrustedCertificatesBytes(sslData.buffer.asUint8List());
  // final backend = await startBackend();
  port = (await getBackendPort())!;
  await Future.delayed(const Duration(seconds: 1));
  runApp(const MyApp());
  // ProcessSignal.sigint.watch().listen((_) {
  //   backend?.kill();
  // });
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
        title: 'Riot Music',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}
