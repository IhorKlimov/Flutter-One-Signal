import 'package:flutter/material.dart';
import 'package:flutter_one_signal/flutter_one_signal.dart';

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

class Home extends StatefulWidget {
  final String title;

  Home({Key key, this.title}) : super(key: key);

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  static const String DEFAULT_APP_ID = '66083bef-bff9-4be6-b45d-c4666bcdd752';
  static const String TEST_APP_ID = '5e92b9ef-1336-4ca8-8357-7c8e3dd92e9c';

  @override
  void initState() {
    super.initState();
    _initOneSignal();
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

  _initOneSignal() async {
    var notificationsPermissionGranted = await FlutterOneSignal.startInit(
        appId: TEST_APP_ID,
        // todo Replace with your own, this won't work for you
        notificationOpenedHandler: (notification) {
          print('opened notification: $notification');
          Navigator.of(context).pushNamed('pageTwo');
        },
        notificationReceivedHandler: (notification) {
          print('received notification: $notification');
        });
    print(
        'Push notification permission granted $notificationsPermissionGranted');

    FlutterOneSignal.sendTag('userId', 'demoUserId');

    FlutterOneSignal.setEmail('name@email.com');

    var userId = await FlutterOneSignal.getUserId();
    print("Received $userId");
  }
}

class PageTwo extends StatefulWidget {
  final String title;

  PageTwo({Key key, this.title}) : super(key: key);

  @override
  _PageTwoState createState() => new _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text('Page two'),
      ),
    );
  }
}
