import 'package:firebase_messaging/firebase_messaging.dart';

class FCMHelper {
  FCMHelper._();
  static final FCMHelper fcmHelper = FCMHelper._();

  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // fetch fcm token
  Future<String?> fetchFCMToken() async {
    return await firebaseMessaging.getToken();
  }
}
