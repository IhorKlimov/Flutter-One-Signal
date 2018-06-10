import 'package:flutter/material.dart';
import 'package:flutter_one_signal_example/home.dart';
import 'package:flutter_one_signal_example/page_two.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(title: 'Flutter One Signal'),
      routes: {
        'pageTwo': (context) => PageTwo(title: 'Page Two'),
      },
    );
  }
}
