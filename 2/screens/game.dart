import 'dart:math';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final int scoreLimit;

  const GameScreen({super.key, required this.scoreLimit});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _userScore = 0;
  int _appScore = 0;
  String? _userChoice;
  String? _appChoice;
  final Random _random = Random();
  bool _isRoundActive = false;
  bool _isGameOver = false;

  int get _scoreLimit => widget.scoreLimit;

  void _playRound(String userChoice) {
    setState(() {
      _isRoundActive = true;
      _userChoice = userChoice;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      int randomIndex = _random.nextInt(3);
      List<String> choices = ['🗿', '✂️', '📄'];
      String appCh = choices[randomIndex];

      String roundResult = _determineWinner(userChoice, appCh);

      setState(() {
        _appChoice = appCh;
        if (roundResult == 'user') {
          _userScore++;
        } else if (roundResult == 'app') {
          _appScore++;
        }
      });

      _checkGameOver();

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _isRoundActive = false;
          });
        }
      });
    });
  }

  String _determineWinner(String user, String app) {
    if (user == app) return 'draw';
    if ((user == '🗿' && app == '✂️') ||
        (user == '✂️' && app == '📄') ||
        (user == '📄' && app == '🗿')) {
      return 'user';
    } else {
      return 'app';
    }
  }

  void _checkGameOver() {
    if (_userScore >= _scoreLimit || _appScore >= _scoreLimit) {
      setState(() {
        _isGameOver = true;
      });
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    String title = _userScore >= _scoreLimit
        ? 'Поздравляем! Вы выиграли! 🎉'
        : 'Приложение победило! 😢';

    Future.delayed(const Duration(milliseconds: 1500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            actions: <Widget>[
              TextButton(
                child: const Text('В главное меню'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/menu');
                },
              ),
              TextButton(
                child: const Text('Играть снова'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetGame();
                },
              ),
            ],
          );
        },
      );
    });
  }

  void _resetGame() {
    setState(() {
      _userScore = 0;
      _appScore = 0;
      _userChoice = null;
      _appChoice = null;
      _isGameOver = false;
      _isRoundActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 38.0),
            child: Center(
              child: Text(
                '$_userScore : $_appScore',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: Text(
                'Лимит: $_scoreLimit',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: [
                const Text(
                  'Ход приложения:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Text(_appChoice ?? '❓', style: const TextStyle(fontSize: 80)),
              ],
            ),
            Column(
              children: [
                const Text(
                  'Ваш ход:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Text(_userChoice ?? '❓', style: const TextStyle(fontSize: 80)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildChoiceButton('🗿'),
                _buildChoiceButton('✂️'),
                _buildChoiceButton('📄'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(String choice) {
    return ElevatedButton(
      onPressed: (_isRoundActive || _isGameOver)
          ? null
          : () {
              _playRound(choice);
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16.0),
        shape: const CircleBorder(),
      ),
      child: Text(choice, style: const TextStyle(fontSize: 50)),
    );
  }
}
