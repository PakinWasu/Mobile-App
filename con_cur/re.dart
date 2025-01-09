import 'package:flutter/material.dart';

class result extends StatelessWidget {
  result({Key? key, required this.thb, required this.cur, required this.bank})
      : super(key: key);
  String thb = '';
  String cur = '';
  String bank = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('result'),
      ),
      body: Column(
        children: [Text(thb + cur + bank)],
      ),
    );
  }
}
