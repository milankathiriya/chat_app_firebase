import 'dart:developer';

import 'package:chat_app/utils/helpers/auth_helper.dart';
import 'package:chat_app/utils/helpers/firestore_helper.dart';
import 'package:chat_app/views/components/my_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String receiver_id = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Page"),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              flex: 16,
              child: FutureBuilder(
                future: FirestoreHelper.firestoreHelper
                    .fetchMessages(receiver_id: receiver_id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("ERROR: ${snapshot.error}"),
                    );
                  } else {
                    // Data is available
                    return StreamBuilder(
                      stream: snapshot.data,
                      builder: (context, ss) {
                        if (ss.hasError) {
                          return Center(
                            child: Text("ERROR: ${ss.error}"),
                          );
                        } else if (ss.hasData) {
                          List<QueryDocumentSnapshot<Map<String, dynamic>>>
                              allDocs = (ss.data == null) ? [] : ss.data!.docs;

                          return ListView.builder(
                            reverse: true,
                            itemCount: allDocs.length,
                            itemBuilder: (context, i) {
                              // Adjust this part according to your document structure
                              return Row(
                                mainAxisAlignment:
                                    (allDocs[i].data()["sent_by"] ==
                                            AuthHelper
                                                .firebaseAuth.currentUser!.uid)
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // TODO: use other Material widget instead of Cupertino widget
                                      CupertinoContextMenu(
                                        actions: [
                                          CupertinoContextMenuAction(
                                            child: Text("Update"),
                                            onPressed: () async {
                                              // TODO: call the update chat logic
                                              await FirestoreHelper
                                                  .firestoreHelper
                                                  .updateMessage(
                                                receiver_id: receiver_id,
                                                msgDocId: allDocs[i].id,
                                                newMessage: "updated msg",
                                              );
                                            },
                                          ),
                                          CupertinoContextMenuAction(
                                            child: Text("Delete"),
                                            isDestructiveAction: true,
                                            onPressed: () async {
                                              // call the delete chat logic
                                              await FirestoreHelper
                                                  .firestoreHelper
                                                  .deleteMessage(
                                                      receiver_id: receiver_id,
                                                      msgDocId: allDocs[i].id);

                                              try {
                                                Navigator.pop(context);
                                              } catch (e) {
                                                log("$e");
                                              }
                                            },
                                          ),
                                        ],
                                        child: Material(
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                                "${allDocs[i].data()["msg"]}"),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                          "${(allDocs[i].data()["timestamp"] as Timestamp).toDate()}"),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: chatController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Enter your msg..."),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () async {
                        await FirestoreHelper.firestoreHelper.sendMessage(
                            receiver_id: receiver_id, msg: chatController.text);

                        chatController.clear();
                      },
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
