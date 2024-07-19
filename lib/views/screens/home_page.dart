import 'package:chat_app/utils/helpers/auth_helper.dart';
import 'package:chat_app/utils/helpers/firestore_helper.dart';
import 'package:chat_app/views/components/my_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        title: Text("Home Page"),
        centerTitle: true,
      ),
      drawer: MyDrawer(user: user),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder(
          stream: FirestoreHelper.firestoreHelper.fetchAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("ERROR: ${snapshot.error}"),
              );
            } else if (snapshot.hasData) {
              QuerySnapshot<Map<String, dynamic>>? querySnapshot =
                  snapshot.data;

              List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                  (querySnapshot != null) ? querySnapshot.docs : [];

              return (allDocs.isEmpty)
                  ? Center(
                      child: Text("No any users...."),
                    )
                  : ListView.builder(
                      itemCount: allDocs.length,
                      itemBuilder: (context, i) {
                        Timestamp timestamp = allDocs[i].data()["created_at"];

                        DateTime dateTime = timestamp.toDate();

                        return (allDocs[i].data()["email"] ==
                                AuthHelper.firebaseAuth.currentUser!.email)
                            ? Container()
                            : ListTile(
                                leading: CircleAvatar(
                                  radius: 20,
                                  child: Text(allDocs[i]
                                      .data()["email"][0]
                                      .toString()
                                      .toUpperCase()),
                                ),
                                title: Text("${allDocs[i].data()["email"]}"),
                                subtitle: Text(
                                    "${dateTime.day}-${dateTime.month}-${dateTime.year} | ${dateTime.hour}:${dateTime.minute}"),
                                onTap: () async {
                                  // call the logic of creating a chatroom
                                  await FirestoreHelper.firestoreHelper
                                      .createChatroom(
                                          receiver_id:
                                              allDocs[i].data()["auth_uid"]);
                                  Navigator.of(context).pushNamed("chat_page",
                                      arguments: allDocs[i].data()["auth_uid"]);
                                },
                              );
                      },
                    );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
