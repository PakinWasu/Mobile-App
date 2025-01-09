import 'package:flutter/material.dart';
import 're.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String cur = '1';
  final moneybath = TextEditingController();
  String bank = 'scb';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            TextFormField(
              controller: moneybath,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'กรอกเงินบาท'),
            ),
            Text('Select Curr'),
            ListTile(
              title: Text('US'),
              leading: Radio(
                value: 1,
                groupValue: cur,
                onChanged: (value) {
                  setState(() {
                    cur = '0.029';
                  });
                },
                activeColor: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('yen'),
              leading: Radio(
                value: 1,
                groupValue: cur,
                onChanged: (value) {
                  setState(() {
                    cur = '4.56';
                  });
                },
                activeColor: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Euro'),
              leading: Radio(
                value: 1,
                groupValue: cur,
                onChanged: (value) {
                  setState(() {
                    cur = '0.028';
                  });
                },
                activeColor: Colors.blue,
              ),
            ),
            ElevatedButton(
              child: Text('Convert'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return result(
                    cur: cur,
                    bank: bank,
                    thb: moneybath.text,
                  );
                }));
              },
            )
          ],
        ));
  }
}
