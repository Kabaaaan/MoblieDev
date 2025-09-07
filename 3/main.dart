import 'package:flutter/material.dart';
import 'calculationPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'converter_app',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CalculationPage(),
    );
  }
}
