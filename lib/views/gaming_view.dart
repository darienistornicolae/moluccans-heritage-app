import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class GamingView extends StatelessWidget {
  const GamingView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Kamp Wyldemerk'),
          border: const Border(
            bottom: BorderSide(
              color: CupertinoColors.separator,
              width: 1.0,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.game_controller,
                size: 80,
                color: CupertinoColors.systemGrey,
              ),
              SizedBox(height: 24),
              Text(
                'Gaming',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Play games and have fun',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_esports,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Gaming',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Play games and have fun',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

