import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'views/main_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Mapbox for Android and iOS
  if (!kIsWeb) {
    MapboxOptions.setAccessToken(
      'pk.eyJ1Ijoib3NtYW4yMDAwIiwiYSI6ImNtaXl3MHV5cTBtc2EzZXM3djdrZHJuMDAifQ.KsFzVUmVQoSJJCyNBLosMQ',
    );
  }
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return MaterialApp(
        title: 'Moluccans Heritage App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const MainView(),
      );
    } else if (Platform.isIOS) {
      return const CupertinoApp(
        title: 'Moluccans Heritage App',
        debugShowCheckedModeBanner: false,
        home: MainView(),
      );
    } else if (Platform.isAndroid) {
      // Android-specific Material theme
      return MaterialApp(
        title: 'Moluccans Heritage App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          // Android-specific optimizations
          platform: TargetPlatform.android,
        ),
        debugShowCheckedModeBanner: false,
        home: const MainView(),
      );
    } else {
      // Fallback for other platforms (Linux, Windows, macOS)
      return MaterialApp(
        title: 'Moluccans Heritage App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const MainView(),
      );
    }
  }
}