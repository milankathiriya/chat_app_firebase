import 'dart:convert';
import 'dart:developer';

import 'package:firebase_learning_app/utils/helpers/api_helper.dart';
import 'package:firebase_learning_app/utils/helpers/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../utils/helpers/fcm_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String email = "";
  String password = "";

  @override
  void initState() {
    super.initState();
    getFCMToken();
  }

  getFCMToken() async {
    String? token = await FCMHelper.fcmHelper.fetchFCMToken();

    log("--------------");
    log(token!);
    log("--------------");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              child: Text("Send FCM"),
              onPressed: () async {
                await APIHelper.apiHelper.sendFCM(
                  title: "NEW API TITLE",
                  body: "NEW API BODY",
                );
              },
            ),
            ElevatedButton(
              child: Text("Sign Up"),
              onPressed: validateAndSignUp,
            ),
            ElevatedButton(
              child: Text("Sign In"),
              onPressed: validateAndSignIn,
            ),
            ElevatedButton(
              child: Text("Sign In with Google"),
              onPressed: () async {
                Map<String, dynamic> res =
                    await AuthHelper.authHelper.signInWithGoogle();

                if (res['user'] != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Sign In successfull..."),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  Navigator.of(context)
                      .pushReplacementNamed('/', arguments: res['user']);
                } else if (res['error'] != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Sign In failed..."),
                      backgroundColor: Colors.red,
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
        builder: (context) {
          return AlertDialog(
            title: Text("Sign Up"),
            content: Form(
              key: signUpFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: emailController,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Please enter email first...";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      email = val!;
                    },
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                      hintText: "Enter your email here",
                      labelText: "Email",
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Please enter password first...";
                      } else if (val!.length <= 6) {
                        return "Password must be greater than 6 letters...";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      password = val!;
                    },
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.security),
                      border: OutlineInputBorder(),
                      hintText: "Enter your password here",
                      labelText: "Password",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                child: Text("Cancel"),
                onPressed: () {
                  emailController.clear();
                  passwordController.clear();

                  email = "";
                  password = "";

                  Navigator.of(context).pop();
                },
              ),
              OutlinedButton(
                child: Text("Sign Up"),
                onPressed: () async {
                  if (signUpFormKey.currentState!.validate()) {
                    signUpFormKey.currentState!.save();

                    Map<String, dynamic> res = await AuthHelper.authHelper
                        .signUpUser(email: email, password: password);

                    if (res['user'] != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Sign Up successfull..."),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.of(context).pop();
                    } else if (res['error'] != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${res['error']}"),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                        ),
                      );

                      Navigator.of(context).pop();
                    }
                  }

                  emailController.clear();
                  passwordController.clear();

                  email = "";
                  password = "";
                },
              ),
            ],
          );
        });
  }

  validateAndSignIn() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Sign In"),
            content: Form(
              key: signInFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: emailController,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Please enter email first...";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      email = val!;
                    },
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                      hintText: "Enter your email here",
                      labelText: "Email",
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Please enter password first...";
                      } else if (val!.length <= 6) {
                        return "Password must be greater than 6 letters...";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      password = val!;
                    },
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.security),
                      border: OutlineInputBorder(),
                      hintText: "Enter your password here",
                      labelText: "Password",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                child: Text("Cancel"),
                onPressed: () {
                  emailController.clear();
                  passwordController.clear();

                  email = "";
                  password = "";

                  Navigator.of(context).pop();
                },
              ),
              OutlinedButton(
                child: Text("Sign In"),
                onPressed: () async {
                  if (signInFormKey.currentState!.validate()) {
                    signInFormKey.currentState!.save();

                    Map<String, dynamic> res = await AuthHelper.authHelper
                        .signInUser(email: email, password: password);

                    if (res['user'] != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Sign In successfull..."),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/', (route) => false,
                          arguments: res['user']);
                    } else if (res['error'] != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${res['error']}"),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                        ),
                      );

                      Navigator.of(context).pop();
                    }
                  }

                  emailController.clear();
                  passwordController.clear();

                  email = "";
                  password = "";
                },
              ),
            ],
          );
        });
  }
}
