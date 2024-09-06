import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_learning_app/utils/helpers/firestore_helper.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String receiverEmail = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat Page\n${receiverEmail}",
          textAlign: TextAlign.center,
        ),
        toolbarHeight: 80,
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              flex: 18,
              child: FutureBuilder(
                future: FirestoreHelper.firestoreHelper
                    .fetchAllMessages(receiverEmail: receiverEmail),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("ERROR: ${snapshot.error}"),
                    );
                  } else if (snapshot.hasData) {
                    Stream<QuerySnapshot<Map<String, dynamic>>>?
                        messagesStream = snapshot.data;

                    return StreamBuilder(
                      stream: messagesStream,
                      builder: (context, ss) {
                        if (ss.hasError) {
                          return Center(
                            child: Text("ERROR: ${ss.error}"),
                          );
                        } else if (ss.hasData) {
                          QuerySnapshot<Map<String, dynamic>>? data = ss.data;

                          List<QueryDocumentSnapshot<Map<String, dynamic>>>
                              allDocs = (data == null) ? [] : data.docs;

                          return (allDocs.isEmpty)
                              ? Center(
                                  child: Text("No any messages yet..."),
                                )
                              : ListView.builder(
                                  reverse: true,
                                  itemCount: allDocs.length,
                                  itemBuilder: (context, i) {
                                    return Row(
                                      mainAxisAlignment: (receiverEmail ==
                                              allDocs[i].data()['sender'])
                                          ? MainAxisAlignment.start
                                          : MainAxisAlignment.end,
                                      children: [
                                        Chip(
                                          label: Text(
                                              "${allDocs[i].data()['msg']}"),
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

                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Send a message...",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () async {
                        String msg = messageController.text;

                        // call the logic to send a msg
                        await FirestoreHelper.firestoreHelper
                            .sendMessage(msg: msg, receiver: receiverEmail);

                        messageController.clear();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
