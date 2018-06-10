import 'package:flutter/material.dart';
import 'package:flutter_one_signal/flutter_one_signal.dart';

class Home extends StatefulWidget {
  final String title;

  Home({Key key, this.title}) : super(key: key);

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    FlutterOneSignal.startInit(
        appId: '66083bef-bff9-4be6-b45d-c4666bcdd752',
        // todo Replace with your own, this won't work for you
        notificationOpenedHandler: (notification) {
          print('opened notification: $notification');
        Navigator.of(context).pushNamed('pageTwo');
        },
        notificationReceivedHandler: (notification) {
          print('received notification: $notification');
        });

    FlutterOneSignal.sendTag('userId', 'demoUserId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text('Home page'),
      ),
    );
  }
}
