import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:riot_spotify_flutter/core/constants/app_constants.dart';
import 'package:riot_spotify_flutter/services/backend_service.dart';
import 'package:riot_spotify_flutter/features/home_ref/view/home_screen.dart';

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
    return MaterialApp(
      title: 'Riot Music',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
