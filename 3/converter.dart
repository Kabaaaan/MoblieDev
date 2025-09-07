import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

Future<Map<String, dynamic>> fetchCurrencyRates() async {
  try {
    final response = await http.get(
      Uri.parse('https://www.cbr.ru/scripts/XML_daily.asp'),
      headers: {'User-Agent': 'Dart/3.0 (Currency Rates App)'},
    );

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      final date = document.rootElement.getAttribute('Date');

      final valuteElements = document.findAllElements('Valute');
      var valutesInfo = <String, List<double>>{};

      for (final valute in valuteElements) {
        final charCode = valute.findElements('CharCode').first.text;
        final nominal = valute.findElements('Nominal').first.text;
        final value = valute.findElements('Value').first.text;

        final nominalDouble = double.parse(nominal.replaceAll(',', '.'));
        final valueDouble = double.parse(value.replaceAll(',', '.'));

        valutesInfo[charCode] = [nominalDouble, valueDouble];
      }
      valutesInfo['RUB'] = [1, 1];

      return {'date': date, 'rates': valutesInfo};
    } else {
      return {'date': null, 'rates': {}};
    }
  } catch (e) {
    return {'date': null, 'rates': {}};
  }
}

double converter(
  String? current_valute,
  String? target_valute,
  Map valutes_info,
  double cost,
) {
  List<double> current_valute_info = valutes_info[current_valute];
  List<double> target_valute_info = valutes_info[target_valute];

  double current_valute_to_Ruble = double.parse(
    (current_valute_info[1] / current_valute_info[0]).toStringAsFixed(2),
  );
  double target_valute_to_Ruble = double.parse(
    (target_valute_info[1] / target_valute_info[0]).toStringAsFixed(2),
  );

  double result = (cost * current_valute_to_Ruble) / target_valute_to_Ruble;

  return double.parse(result.toStringAsFixed(2));
}
