import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(BrlToUsdApp());

class BrlToUsdApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoinVerter',
      theme: ThemeData(
        textTheme: GoogleFonts.interTightTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.green.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          labelStyle: TextStyle(color: Colors.green.shade900),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle:
                GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('CoinVerter'),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: ConverterForm(),
        ),
      ),
    );
  }
}

class ConverterForm extends StatefulWidget {
  @override
  _ConverterFormState createState() => _ConverterFormState();
}

class _ConverterFormState extends State<ConverterForm> {
  final _numberFormat = NumberFormat("#,##0.00", "pt_BR");
  final _brlController = TextEditingController();
  final _rateController = TextEditingController(text: '0');
  double _convertedValue = 0.0;

  bool _autoRate = true; // true = cotação automática da API

  String _selectedCurrency = 'USD';
  Map<String, dynamic> _rates = {};
  final List<String> _currencies = [
    'USD',
    'AUD',
    'BRL',
    'CAD',
    'CHF',
    'CLP',
    'CNY',
    'DKK',
    'EUR',
    'GBP',
    'HKD',
    'INR',
    'ISK',
    'JPY',
    'KRW',
    'NZD',
    'PLN',
    'RUB',
    'SEK',
    'SGD',
    'THB',
    'TRY',
    'TWD'
  ];

  @override
  void initState() {
    super.initState();
    if (_autoRate) fetchRates();
  }

  @override
  void dispose() {
    _brlController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> fetchRates() async {
    try {
      final response =
          await http.get(Uri.parse('https://blockchain.info/ticker'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _rates = data;
          _updateRateAndConvert();
        });
      } else {
        throw Exception('Falha ao carregar cotação');
      }
    } catch (e) {
      print('Erro ao buscar cotação: $e');
    }
  }

  void _updateRateAndConvert() {
    if (_rates.containsKey('BRL') && _rates.containsKey(_selectedCurrency)) {
      final brlPerBtc = _rates['BRL']['last'] as num;
      final targetPerBtc = _rates[_selectedCurrency]['last'] as num;

      // Cotação da moeda selecionada em BRL
      final fiatInBrl = brlPerBtc / targetPerBtc;

      _rateController.text = fiatInBrl.toStringAsFixed(2);
      _convert();
    }
  }

  void _convert() {
    final brl =
        double.tryParse(_brlController.text.replaceAll(',', '.')) ?? 0.0;
    final rate =
        double.tryParse(_rateController.text.replaceAll(',', '.')) ?? 1.0;

    setState(() {
      _convertedValue = brl / rate; // BRL ÷ BRL por moeda = valor na moeda
    });
  }

  void _openCurrencySelector() {
    showDialog(
      context: context,
      builder: (context) {
        String search = '';
        List<String> filtered = _currencies;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Escolha a moeda'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Pesquisar moeda',
                    ),
                    onChanged: (value) {
                      setStateDialog(() {
                        search = value.toUpperCase();
                        filtered = _currencies
                            .where((c) => c.contains(search))
                            .toList();
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.maxFinite,
                    height: 200,
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final currency = filtered[index];
                        return ListTile(
                          title: Text(currency),
                          onTap: () {
                            setState(() {
                              _selectedCurrency = currency;
                              _updateRateAndConvert();
                            });
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Cotação automática'),
            ),
            Switch(
              value: _autoRate,
              onChanged: (value) {
                setState(() {
                  _autoRate = value;
                  if (_autoRate) fetchRates();
                });
              },
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _openCurrencySelector,
              child: Text(_selectedCurrency),
            ),
          ],
        ),
        SizedBox(height: 16),
        TextField(
          controller: _brlController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          decoration: InputDecoration(
            labelText: 'Valor em BRL',
            prefixText: 'R\$ ',
          ),
          onChanged: (_) => _convert(),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _rateController,
          readOnly: _autoRate,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          decoration: InputDecoration(
            labelText: 'Cotação ($_selectedCurrency por 1 BRL)',
            hintText: 'ex: 0.19',
            suffixIcon: _autoRate
                ? IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: fetchRates,
                  )
                : null,
          ),
          onChanged: (_) => _convert(),
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: _convert,
          child: Text('Converter'),
        ),
        SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Resultado: ${_selectedCurrency == "BRL" ? "R\$" : "\$"}${_numberFormat.format(_convertedValue)}',
            textAlign: TextAlign.center,
            style: GoogleFonts.interTight(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
          ),
        ),
      ],
    );
  }
}
