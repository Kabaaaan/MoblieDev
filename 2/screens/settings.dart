import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final int initialScoreLimit;
  final Function(int) onScoreLimitChanged;

  const SettingsScreen({
    super.key,
    required this.initialScoreLimit,
    required this.onScoreLimitChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _selectedLimit;

  @override
  void initState() {
    super.initState();
    _selectedLimit = widget.initialScoreLimit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Выберите лимит очков для победы:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ...[3, 5, 7, 10].map((limitValue) {
              return RadioListTile<int>(
                title: Text('До $limitValue очков'),
                value: limitValue,
                groupValue: _selectedLimit,
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedLimit = newValue!;
                  });
                  widget.onScoreLimitChanged(newValue!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Лимит изменен!')),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
