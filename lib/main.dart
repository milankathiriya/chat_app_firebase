import 'package:chat_app/views/screens/chat_page.dart';
import 'package:chat_app/views/screens/home_page.dart';

import 'views/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
