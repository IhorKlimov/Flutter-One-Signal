import 'package:flutter/material.dart';
import 'package:flutter_one_signal/flutter_one_signal.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    FlutterOneSignal.startInit(
        appId:
            '66083bef-bff9-4be6-b45d-c4666bcdd752' // todo Replace with your own, this won't work for you
//      notificationOpenedHandler: (notification) {
//        print(notification);
//      },
        );
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(),
      ),
    );
  }
}
