import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(BrlToUsdApp());

class BrlToUsdApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conversor BRL → USD',
      home: Scaffold(
        appBar: AppBar(title: Text('Conversor BRL → USD')),
        body: Padding(
          padding: EdgeInsets.all(16),
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
  final _brlController = TextEditingController();
  final _rateController =
      TextEditingController(text: '0.19'); // valor padrão aproximado
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _brlController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
          ],
          decoration:
              InputDecoration(labelText: 'Valor em BRL', prefixText: 'R\$ '),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _rateController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
          ],
          decoration: InputDecoration(
              labelText: 'Cotação (USD por 1 BRL)', hintText: 'ex: 0.19'),
        ),
        SizedBox(height: 18),
        ElevatedButton(
          onPressed: _convert,
          child: Text('Converter'),
        ),
        SizedBox(height: 18),
        Text('Resultado: \$${_usd.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 20)),
      ],
      crossAxisAlignment: CrossAxisAlignment.stretch,
    );
  }
}
