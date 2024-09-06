import 'dart:developer';

import 'package:firebase_learning_app/utils/helpers/local_push_notification_helper.dart';
import 'package:firebase_learning_app/views/screens/chat_page.dart';
import 'package:firebase_learning_app/views/screens/home_page.dart';
import 'package:firebase_learning_app/views/screens/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await LocalPushNotificationHelper.localPushNotificationHelper
      .showSimpleNotification(
    sender: message.notification!.title!,
    msg: message.notification!.body!,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // It executes when a foreground notification is arrived
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    await LocalPushNotificationHelper.localPushNotificationHelper
        .showSimpleNotification(
      sender: message.notification!.title!,
      msg: message.notification!.body!,
    );
  });

  // It executes when a background notification is arrived
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'login_page',
    routes: {
      'login_page': (context) => LoginPage(),
      '/': (context) => HomePage(),
      'chat_page': (context) => ChatPage(),
    },
  ));
}
