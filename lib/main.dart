import 'package:chat_app/utils/helpers/local_notification_helper.dart';
import 'package:chat_app/views/screens/chat_page.dart';
import 'package:chat_app/views/screens/home_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'views/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> handleBackgroundFCMNotification(
    RemoteMessage remoteMessage) async {
  print("======Background/Terminated STATE========");
  print("FCM Notification arrived...");
  print("==============");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Receive FCM notifications only if our app is in foreground state
  FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
    print("======FOREGROUND STATE========");
    print("FCM Notification arrived...");
    print("==============");
    LocalNotificationHelper.localNotificationHelper.showSimpleNotification(
      title: remoteMessage.notification!.title,
      body: remoteMessage.notification!.body,
    );
  });

  // Receive FCM notifications only if our app is in background / terminated state
  FirebaseMessaging.onBackgroundMessage(handleBackgroundFCMNotification);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
      initialRoute: 'login_page',
      routes: {
        'login_page': (context) => LoginPage(),
        '/': (context) => HomePage(),
        'chat_page': (context) => ChatPage(),
      },
    ),
  );
}
