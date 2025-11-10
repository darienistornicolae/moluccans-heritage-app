import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'viewmodels/counter_viewmodel.dart';
import 'views/ios/counter_view_ios.dart';
import 'views/android/counter_view_android.dart';
import 'views/web/counter_view_web.dart';

enum PlatformType { web, ios, android }

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CounterViewModel(),
      child: _buildPlatformApp(),
    );
  }

  PlatformType _getPlatformType() {
    if (kIsWeb) {
      return PlatformType.web;
    } else if (Platform.isIOS) {
      return PlatformType.ios;
    } else {
      return PlatformType.android;
    }
  }

  Widget _buildPlatformApp() {
    switch (_getPlatformType()) {
      case PlatformType.web:
        return MaterialApp(
          title: 'Moluccans Heritage App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
            useMaterial3: true,
          ),
          home: const CounterViewWeb(),
        );
      case PlatformType.ios:
        return const CupertinoApp(
          title: 'Moluccans Heritage App',
          home: CounterViewIOS(),
        );
      case PlatformType.android:
        return MaterialApp(
          title: 'Moluccans Heritage App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const CounterViewAndroid(),
        );
    }
  }
}
