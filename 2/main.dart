import 'package:flutter/material.dart';
import 'screens/menu.dart';
import 'screens/settings.dart';
import 'screens/game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MenuScreen(),
      routes: {
        '/menu': (context) => const MenuScreen(),
        '/settings': (context) => SettingsScreen(
          initialScoreLimit: 3,
          onScoreLimitChanged: (newLimit) {},
        ),
        '/game': (context) => const GameScreen(scoreLimit: 3),
      },
    );
  }
}
