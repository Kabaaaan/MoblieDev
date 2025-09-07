import 'package:flutter/material.dart';
import 'converter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CalculationPage extends StatefulWidget {
  @override
  _CalculationPageState createState() => _CalculationPageState();
}

class _CalculationPageState extends State<CalculationPage> {
  // var valutesData = _getData;
  String? _selectedOption1;
  String? _selectedOption2;
  Map valutesData = {};
  String date = '';
  final TextEditingController _textController = TextEditingController();
  final double _elementWidth = 300.0;
  final double _verticalPadding = 8.0;

  List<String> _options1 = [];
  List<String> _options2 = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrencyData();
  }

  Future<void> _loadCurrencyData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _errorMessage = 'Нет интернет-соединения';
        _isLoading = false;
      });
      return;
    }

      final data = await fetchCurrencyRates();
      valutesData = data['rates'];
      date = data['date'];

      if (data['rates'] != null && data['rates'] is Map<String, dynamic>) {
        final rates = data['rates'] as Map<String, dynamic>;
        final currencyCodes = rates.keys.toList();

        setState(() {
          _options1 = currencyCodes;
          _options2 = currencyCodes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Данные не получены';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки данных: $e';
        _isLoading = false;
      });
    }
  }

  void _calculate() {
    if (_selectedOption1 == null ||
        _selectedOption2 == null ||
        _textController.text.isEmpty) {
      _showErrorDialog('Пожалуйста, заполните все поля');
      return;
    }

    try {
      double cost = double.parse(_textController.text);
      if (cost <= 0) {
        _showErrorDialog('Введите положительное число');
        return;
      }

      double result = converter(
        _selectedOption1,
        _selectedOption2,
        valutesData,
        cost,
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Конвертертация 💰', style: TextStyle(fontSize: 18)),
            content: Text(
              '$_selectedOption1 -> $_selectedOption2\n'
              '$cost -> ${result.toStringAsFixed(2)}\n',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Назад'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showErrorDialog('Введите корректное число');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ошибка'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Конвертер валют')),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _elementWidth,
                padding: EdgeInsets.symmetric(vertical: _verticalPadding),
                child: Text('Курс валют на $date'),
              ),
              Container(
                width: _elementWidth,
                padding: EdgeInsets.symmetric(vertical: _verticalPadding),
                child: DropdownButtonFormField<String>(
                  value: _selectedOption1,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ваша валюта',
                  ),
                  items: _options1.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedOption1 = newValue;
                    });
                  },
                  isExpanded: true,
                  menuMaxHeight: 300,
                  dropdownColor: Colors.white,
                ),
              ),

              Container(
                width: _elementWidth,
                padding: EdgeInsets.symmetric(vertical: _verticalPadding),
                child: DropdownButtonFormField<String>(
                  value: _selectedOption2,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Целевая валюта',
                  ),
                  items: _options2.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedOption2 = newValue;
                    });
                  },
                  isExpanded: true,
                  menuMaxHeight: 300,
                  dropdownColor: Colors.white,
                ),
              ),

              Container(
                width: _elementWidth,
                padding: EdgeInsets.symmetric(vertical: _verticalPadding),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Кол-во валюты',
                  ),
                ),
              ),

              // Кнопка
              Container(
                width: _elementWidth,
                padding: EdgeInsets.symmetric(vertical: _verticalPadding),
                child: ElevatedButton(
                  onPressed: _calculate,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Вычислить', style: TextStyle(fontSize: 16.0)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
