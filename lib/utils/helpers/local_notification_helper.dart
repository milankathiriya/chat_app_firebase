import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationHelper {
  LocalNotificationHelper._();
  static final LocalNotificationHelper localNotificationHelper =
      LocalNotificationHelper._();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initLocalNotifications() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings("mipmap/ic_launcher");
    DarwinInitializationSettings darwinInitializationSettings =
        const DarwinInitializationSettings();

    InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: darwinInitializationSettings);

    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
      log("************");
      log("${response.payload}");
      log("************");
    });
  }

  Future<void> showSimpleNotification(
      {required String? title, required String? body}) async {
    await initLocalNotifications();

    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails("1", "Simple Notification Channel",
            priority: Priority.max, importance: Importance.max);
    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        1, title ?? "Sample", body ?? "Dummy", notificationDetails,
        payload: "Sample Payload");
  }

  Future<void> showScheduledNotification() async {
    await initLocalNotifications();

    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails("1", "Simple Notification Channel",
            priority: Priority.max, importance: Importance.max);
    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      2,
      "Scheduled Notification",
      "Dummuy Desc",
      tz.TZDateTime.now(tz.local).add(Duration(seconds: 3)),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showBigPictureNotification() async {
    await initLocalNotifications();

    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "1",
      "Simple Notification Channel",
      priority: Priority.max,
      importance: Importance.max,
      styleInformation: BigPictureStyleInformation(
        DrawableResourceAndroidBitmap("mipmap/ic_launcher"),
        largeIcon: DrawableResourceAndroidBitmap("mipmap/ic_launcher"),
      ),
    );
    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        1, "Simple Notification", "Dummy Desc", notificationDetails,
        payload: "Sample Payload");
  }

  Future<void> showMediaStyleNotification() async {
    await initLocalNotifications();

    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "1",
      "Simple Notification Channel",
      priority: Priority.max,
      importance: Importance.max,
      styleInformation: MediaStyleInformation(),
      icon: "mipmap/ic_launcher",
      largeIcon: DrawableResourceAndroidBitmap("mipmap/ic_launcher"),
      colorized: true,
      color: Colors.red,
    );
    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        1, "Simple Notification", "Dummy Desc", notificationDetails,
        payload: "Sample Payload");
  }
}
