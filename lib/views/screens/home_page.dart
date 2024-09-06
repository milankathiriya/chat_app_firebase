import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_learning_app/utils/helpers/auth_helper.dart';
import 'package:firebase_learning_app/utils/helpers/firestore_helper.dart';
import 'package:firebase_learning_app/utils/helpers/local_push_notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    User? user = ModalRoute.of(context)!.settings.arguments as User?;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home Page\n${user!.email}",
          textAlign: TextAlign.center,
        ),
        toolbarHeight: 80,
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.power_settings_new),
            onPressed: () async {
              await AuthHelper.authHelper.signOutUser();

              Navigator.of(context)
                  .pushNamedAndRemoveUntil('login_page', (route) => false);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: CircleAvatar(
                radius: 80,
                backgroundImage: (user == null)
                    ? null
                    : (user.photoURL == null)
                        ? null
                        : NetworkImage(user.photoURL as String),
              ),
            ),
            (user == null) ? Container() : Text("${user.email}"),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirestoreHelper.firestoreHelper.fetchAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("ERROR: ${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            QuerySnapshot<Map<String, dynamic>>? data = snapshot.data;

            List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                (data == null) ? [] : data.docs;

            return (allDocs.isEmpty)
                ? Center(
                    child: Text("No any users available..."),
                  )
                : ListView.builder(
                    itemCount: allDocs.length,
                    itemBuilder: (context, i) {
                      return (user!.email == allDocs[i].data()['email'])
                          ? Container()
                          : Card(
                              margin: const EdgeInsets.all(10),
                              elevation: 5,
                              child: ListTile(
                                title: Text("${allDocs[i].data()['email']}"),
                                subtitle: Text("${allDocs[i].data()['uid']}"),
                                onTap: () {
                                  Navigator.of(context).pushNamed('chat_page',
                                      arguments: allDocs[i].data()['email']);
                                },
                              ),
                            );
                    },
                  );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
