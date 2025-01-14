import 'package:flutter/material.dart';
import 'result_page.dart';

void main() {
  runApp(CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedBank = 'TMBThanachart Bank (TTB)';
  String _selectedCurrency = 'Euro (EUR)';

  final List<String> _banks = [
    'Krungthai Bank (KTB)',
    'Siam Commercial Bank (SCB)',
    'TMBThanachart Bank (TTB)'
  ];

  final List<String> _currencies = [
    'US Dollar (USD)',
    'Japanese Yen (JPY)',
    'Euro (EUR)'
  ];

  void _convertCurrency() {
    if (_amountController.text.isEmpty) return;
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    double result = 0.0;

    if (_selectedBank == 'TMBThanachart Bank (TTB)') {
      if (_selectedCurrency == 'US Dollar (USD)') result = amount * 0.03;
      if (_selectedCurrency == 'Japanese Yen (JPY)') result = amount * 4.0;
      if (_selectedCurrency == 'Euro (EUR)') result = amount * 0.027;
    } else if (_selectedBank == 'Siam Commercial Bank (SCB)') {
      if (_selectedCurrency == 'US Dollar (USD)') result = amount * 0.031;
      if (_selectedCurrency == 'Japanese Yen (JPY)') result = amount * 3.95;
      if (_selectedCurrency == 'Euro (EUR)') result = amount * 0.025;
    } else if (_selectedBank == 'Krungthai Bank (KTB)') {
      if (_selectedCurrency == 'US Dollar (USD)') result = amount * 0.03;
      if (_selectedCurrency == 'Japanese Yen (JPY)') result = amount * 3.98;
      if (_selectedCurrency == 'Euro (EUR)') result = amount * 0.026;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          bank: _selectedBank,
          result: result,
          currency: _selectedCurrency,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter amount in Thai Baht',
                prefixText: '฿',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedBank,
              items: _banks.map((bank) {
                return DropdownMenuItem(
                  value: bank,
                  child: Text(bank),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBank = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Bank',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Currency:'),
                ..._currencies.map((currency) {
                  return RadioListTile(
                    title: Text(currency),
                    value: currency,
                    groupValue: _selectedCurrency,
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrency = value!;
                      });
                    },
                  );
                }).toList(),
              ],
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: _convertCurrency,
                child: Text('Convert'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
