import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() => runApp(BrlToUsdApp());

// main
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

class _ConverterFormState extends State<ConverterForm> {
  final _numberFormat = NumberFormat("#,##0.00", "pt_BR");
  final _brlController = TextEditingController();
  final _rateController = TextEditingController(text: '5.3');
  double _usd = 0.0;

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
  void dispose() {
    _brlController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  // Resultado
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          decoration: InputDecoration(
            labelText: 'Cotação (USD por 1 BRL)',
            hintText: 'ex: 5.5',
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
