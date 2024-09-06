import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalPushNotificationHelper {
  LocalPushNotificationHelper._();
  static final LocalPushNotificationHelper localPushNotificationHelper =
      LocalPushNotificationHelper._();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // initialize local push notification
  Future<void> initNotification() async {
    AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("mipmap/ic_launcher");
    DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings();

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (response) {
      log("==========");
      log("PAYLOAD: ${response.payload}");
      log("==========");
    });
  }

  // show simple notification
  Future<void> showSimpleNotification(
      {required String sender, required String msg}) async {
    await initNotification();

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "1",
      "Simple Notification",
      priority: Priority.max,
      importance: Importance.max,
    );
    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        1, sender, msg, notificationDetails,
        payload: "Sample Data (Payload)");
  }
}
