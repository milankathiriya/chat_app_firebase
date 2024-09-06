import 'dart:convert';
import 'dart:developer';
import 'package:firebase_learning_app/utils/helpers/fcm_helper.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class APIHelper {
  APIHelper._();
  static final APIHelper apiHelper = APIHelper._();

  // OLD Way: send a FCM notification using an API
  Future<void> sendFCMNotification() async {
    Map<String, dynamic> myBody = {
      "to": "receiver_token",
      "notification": {
        "title": "Sample Title",
        "body": "Dummy Body",
      },
      "data": {
        "age": 22,
        "school": "PQR",
      },
    };

    var myHeaders = {
      "Content-Type": "application/json",
      "Authorization": "key=server_key",
    };

    http.Response response = await http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      body: jsonEncode(myBody),
      headers: myHeaders,
    );

    var decodedData = jsonDecode(response.body);

    log("$decodedData");
  }

  // NEW Way: For sending a FCM notification using an API
  Future<String> getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(
      await rootBundle.loadString(
          'assets/flutter-firebase-app-42961-firebase-adminsdk-uejer-ff4038ee47.json'),
    );

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final authClient =
        await clientViaServiceAccount(accountCredentials, scopes);
    return authClient.credentials.accessToken.data;
  }

  // NEW Way: send a FCM notification using an API
  Future<void> sendFCM({required String title, required String body}) async {
    String? token = await FCMHelper.fcmHelper.fetchFCMToken();

    final String accessToken = await getAccessToken();

    final String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/flutter-firebase-app-42961/messages:send';

    final Map<String, dynamic> myBody = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
      },
    };

    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(myBody),
    );

    if (response.statusCode == 200) {
      print('-------------------');
      print('Notification sent successfully');
      print('-------------------');
    } else {
      print('-------------------');
      print('Failed to send notification: ${response.body}');
      print('-------------------');
    }
  }
}
