import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(BrlToUsdApp());

// Main
class BrlToUsdApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conversor BRL → USD',
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
          title: Text('Conversor (BRL → USD)'),
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

// Lógica de conversão
class _ConverterFormState extends State<ConverterForm> {
  final _numberFormat = NumberFormat("#,##0.00", "pt_BR");
  final _brlController = TextEditingController();
  final _rateController = TextEditingController(text: '0');
  double _usd = 0.0;

  bool _autoRate = true; // true = cotação automática da API

  @override
  void initState() {
    super.initState();
    if (_autoRate) fetchDollarRate();
  }

  @override
  void dispose() {
    _brlController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> fetchDollarRate() async {
    try {
      final response = await http.get(
        Uri.parse('https://blockchain.info/ticker'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final brlInBtc = data['BRL']['last'];
        final usdInBtc = data['USD']['last'];
        final brlToUsd = brlInBtc / usdInBtc;

        setState(() {
          _rateController.text = brlToUsd.toStringAsFixed(2);
        });
      } else {
        throw Exception('Falha ao carregar cotação');
      }
    } catch (e) {
      print('Erro ao buscar cotação: $e');
    }
  }

  void _convert() {
    final brl =
        double.tryParse(_brlController.text.replaceAll(',', '.')) ?? 0.0;
    final rate =
        double.tryParse(_rateController.text.replaceAll(',', '.')) ?? 0.0;

    setState(() {
      _usd = (rate > 0) ? (brl * rate) : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botão toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              _autoRate ? 'Cotação automática' : 'Cotação manual',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _autoRate = !_autoRate;
                  if (_autoRate) fetchDollarRate();
                });
              },
              child: Icon(Icons.refresh),
              style: ElevatedButton.styleFrom(
                backgroundColor: _autoRate ? Colors.green : Colors.grey,
                minimumSize: Size(40, 40),
                padding: EdgeInsets.zero,
              ),
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
        ),
        SizedBox(height: 16),

        TextField(
          controller: _rateController,
          readOnly: _autoRate, // desativa edição se automático
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          decoration: InputDecoration(
            labelText: 'Cotação (USD por 1 BRL)',
            hintText: 'ex: 0.19',
            suffixIcon: _autoRate
                ? IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: fetchDollarRate,
                  )
                : null,
          ),
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
            'Resultado: \$${_numberFormat.format(_usd)}',
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
