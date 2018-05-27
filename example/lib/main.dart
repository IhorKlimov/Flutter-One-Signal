import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_one_signal/flutter_one_signal.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(

        ),
      ),
    );
  }
}
