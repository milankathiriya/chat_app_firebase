import 'package:chat_app/utils/helpers/firestore_helper.dart';
import 'package:chat_app/views/components/my_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
              child: StreamBuilder(
                stream: FirestoreHelper.firestoreHelper
                    .fetchMessages(receiver_id: receiver_id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("ERROR: ${snapshot.error}"),
                    );
                  } else if (snapshot.hasData) {
                    QuerySnapshot<Map<String, dynamic>>? data = snapshot.data;

                    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                        (data != null) ? data.docs : [];

                    return (allDocs.isEmpty)
                        ? Center(
                            child: Text("No chat has been made yet..."),
                          )
                        : ListView.builder(
                            reverse: true,
                            itemCount: allDocs.length,
                            itemBuilder: (context, i) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ActionChip(
                                        label:
                                            Text("${allDocs[i].data()["msg"]}"),
                                        onPressed: () {},
                                      ),
                                      Text(
                                          "${(allDocs[i].data()["timestamp"] as Timestamp).toDate()}"),
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
