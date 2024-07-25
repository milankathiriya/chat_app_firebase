import 'dart:developer';

import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/utils/helpers/fcm_helper.dart';
import 'package:chat_app/utils/helpers/firestore_helper.dart';
import 'package:chat_app/utils/helpers/local_notification_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/helpers/auth_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? email;
  String? password;

  Future<void> requestPermission() async {
    await AndroidFlutterLocalNotificationsPlugin()
        .requestNotificationsPermission();
    await Permission.notification.request();
    await Permission.accessNotificationPolicy.request();
  }

  Future<void> fetchFCMToken() async {
    String? token = await FCMHelper.fcmHelper.getFCMToken();

    log("==================");
    print("$token");
    log("==================");
  }

  Future handleFCMNotificationsInteraction() async {
    // This code only executes if our app state is terminated
    RemoteMessage? remoteMessage =
        await FCMHelper.firebaseMessaging.getInitialMessage();

    if (remoteMessage != null) {
      print("==============");
      print("${remoteMessage.notification!.title}");
      print("${remoteMessage.notification!.body}");
      print("${remoteMessage.data['']}");
      print("==============");
    }

    // This code only executes if our app state is background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      print("==============");
      print("${remoteMessage.notification!.title}");
      print("${remoteMessage.notification!.body}");
      print("${remoteMessage.data['']}");
      print("==============");
    });
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
    fetchFCMToken();
    handleFCMNotificationsInteraction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              child: Text("Anonymously Login"),
              onPressed: () async {
                Map<String, dynamic> res =
                    await AuthHelper.authHelper.signInWithAnonymously();

                if (res["user"] != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("User Sign In Successfully..."),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  // push a user to home_page
                  Navigator.of(context)
                      .pushReplacementNamed('/', arguments: res["user"]);
                } else if (res["error"] != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res["error"]),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("User Sign In failed..."),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  child: Text("Sign Up"),
                  onPressed: validateAndSignUp,
                ),
                OutlinedButton(
                  child: Text("Sign In"),
                  onPressed: validateAndSignIn,
                ),
              ],
            ),
            OutlinedButton(
              child: Text("Sign In with Google"),
              onPressed: () async {
                Map<String, dynamic> res =
                    await AuthHelper.authHelper.signInWithGoogle();

                if (res["user"] != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("User Sign In Successfully..."),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  User user = res["user"];

                  UserModel userModel = UserModel(
                    email: user.email!,
                    auth_uid: user.uid,
                    created_at: DateTime.now(),
                    logged_in_at: DateTime.now(),
                  );

                  // call the insertUser()
                  await FirestoreHelper.firestoreHelper
                      .insertUser(userModel: userModel);

                  // push a user to home_page
                  Navigator.of(context)
                      .pushReplacementNamed('/', arguments: res["user"]);
                } else if (res["error"] != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res["error"]),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("User Sign In failed..."),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  validateAndSignUp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Sign UP"),
        content: Form(
          key: signUpFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                validator: (val) {
                  return (val!.isEmpty) ? "Enter email first" : null;
                },
                onSaved: (val) {
                  email = val;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter email",
                  labelText: "Email",
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                validator: (val) {
                  return (val!.isEmpty) ? "Enter password first" : null;
                },
                onSaved: (val) {
                  password = val;
                },
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter password",
                  labelText: "Password",
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          OutlinedButton(
            child: Text("Sign Up"),
            onPressed: () async {
              if (signUpFormKey.currentState!.validate()) {
                signUpFormKey.currentState!.save();

                Map<String, dynamic> res = await AuthHelper.authHelper
                    .signUp(email: email!, password: password!);

                if (res["user"] != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("User Sign Up Successfully..."),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  User user = res["user"];

                  UserModel userModel = UserModel(
                      email: user.email!,
                      auth_uid: user.uid,
                      created_at: DateTime.now());

                  // call the insertUser()
                  await FirestoreHelper.firestoreHelper
                      .insertUser(userModel: userModel);
                } else if (res["error"] != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res["error"]),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("User Sign Up failed..."),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }

                emailController.clear();
                passwordController.clear();

                email = null;
                password = null;

                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  validateAndSignIn() {
    showDialog(
      context: scaffoldKey.currentContext!,
      builder: (context) => AlertDialog(
        title: Text("Sign In"),
        content: Form(
          key: signInFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                validator: (val) {
                  return (val!.isEmpty) ? "Enter email first" : null;
                },
                onSaved: (val) {
                  email = val;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter email",
                  labelText: "Email",
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                validator: (val) {
                  return (val!.isEmpty) ? "Enter password first" : null;
                },
                onSaved: (val) {
                  password = val;
                },
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter password",
                  labelText: "Password",
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          OutlinedButton(
            child: Text("Sign In"),
            onPressed: () async {
              if (signInFormKey.currentState!.validate()) {
                signInFormKey.currentState!.save();

                Map<String, dynamic> res = await AuthHelper.authHelper
                    .signIn(email: email!, password: password!);

                // Navigator.pop(context);

                if (res["user"] != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("User Sign In Successfully..."),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  User user = res["user"];

                  UserModel userModel = UserModel(
                    email: user.email!,
                    auth_uid: user.uid,
                    created_at: DateTime.now(),
                  );

                  // call the insertUser()
                  await FirestoreHelper.firestoreHelper
                      .insertUser(userModel: userModel);

                  // push a user to home_page
                  Navigator.pushReplacementNamed(context, '/',
                      arguments: res["user"]);
                } else if (res["error"] != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res["error"]),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("User Sign In failed..."),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }

                emailController.clear();
                passwordController.clear();

                email = null;
                password = null;
              }
            },
          ),
        ],
      ),
    );
  }
}
