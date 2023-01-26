import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_notification_linq/flutter_notification_linq.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_notification_linq/src/linq_remote_message.dart';

void main() async{
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   // name: 'linq-pros',
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterNotificationLinqPlugin = FlutterNotificationLinq();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    // FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    //   print("fcmtoken update: $fcmToken");
    // }).onError((err) {
    //   // Error getting token.
    // });
    // FirebaseMessaging.onMessageOpenedApp.listen((m) {
    //
    //   print(m);
    // });

    FlutterNotificationLinq.onMessageOpenedApp.listen((message) {

      print(message);
    });
    // uploadFcmToken();

  }
  // uploadFcmToken() async {
  //   final fcmToken = await FirebaseMessaging.instance.getToken();
  //   print("fcmtoken upload: $fcmToken");
  //
  //   LinqRemoteMessage? initialMessage =
  //   await FlutterNotificationLinq.getInitialMessage();
  //
  //   // If the message also contains a data property with a "type" of "chat",
  //   // navigate to a chat screen
  //   if (initialMessage != null) {
  //     print(initialMessage);
  //     // _handleMessage2(initialMessage);
  //   }
  //
  // }



  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterNotificationLinqPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
