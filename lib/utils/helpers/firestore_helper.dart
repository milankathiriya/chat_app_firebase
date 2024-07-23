import 'dart:developer';

import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/utils/helpers/auth_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  FirestoreHelper._();
  static final FirestoreHelper firestoreHelper = FirestoreHelper._();

  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // insert UserModel object into users collection
  Future<void> insertUser({required UserModel userModel}) async {
    // Generate Auto-Increment ID
    // Fetch id from records collections' users document
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await db.collection("records").doc("users").get();
    Map<String, dynamic>? data = documentSnapshot.data();

    int id = (data == null) ? 0 : data["id"];

    // Fetch counter from records collections' users document
    int counter = (data == null) ? 0 : data["counter"];

    // check if the email is already exists in users collection or not
    QuerySnapshot<Map<String, dynamic>>? querySnapshotAllUsers =
        await db.collection("users").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allUsersDocs =
        querySnapshotAllUsers.docs;

    bool isUserExists = false;
    int existingUserId = 0;

    allUsersDocs
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.data()["email"] == userModel.email) {
        isUserExists = true;
        existingUserId = int.parse(snapshot.id);
      }
    });

    if (isUserExists == false) {
      // Increment the id
      id = id + 1;

      // Add a document of user with the id
      await db.collection("users").doc("$id").set(
        {
          "email": userModel.email,
          "auth_uid": userModel.auth_uid,
          "created_at": userModel.created_at,
          "logged_in_at": userModel.logged_in_at,
        },
      );

      // Update the incremented id in records collections' users document
      await db.collection("records").doc("users").update({"id": id});

      // Increment the counter
      counter = counter + 1;

      // Update the counter by incrementing with 1 in records collections' users document
      await db.collection("records").doc("users").update({"counter": counter});
    }

    // update logged_in_at field
    if (isUserExists == true) {
      log("========");
      log("$isUserExists");
      log("========");
      await db.collection("users").doc("$existingUserId").update(
        {
          "logged_in_at": DateTime.now(),
        },
      );
    }
  }

  // fetch all users
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllUsers() {
    return db.collection("users").snapshots();
  }

  // create the chatroom
  Future<void> createChatroom({required String receiver_id}) async {
    await db.collection("chatrooms").doc(receiver_id).set({
      "users": [receiver_id, AuthHelper.firebaseAuth.currentUser!.uid]
    });
  }

  // create a chat subcollection and add message into it
  Future<void> sendMessage(
      {required String receiver_id, required String msg}) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshots =
        await db.collection("chatrooms").get();

    List<dynamic> users = [];
    String docId = receiver_id;

    querySnapshots.docs.forEach((DocumentSnapshot<Map<String, dynamic>> doc) {
      users = doc.data()?["users"] ?? []; // Use null check operator for safety
      if (users.contains(receiver_id) &&
          users.contains(AuthHelper.firebaseAuth.currentUser!.uid)) {
        // get doc id
        docId = doc.id;
      }
    });

    await db.collection("chatrooms").doc(docId).collection("chat").add({
      "msg": msg,
      "sent_by": AuthHelper.firebaseAuth.currentUser!.uid,
      "received_by": receiver_id,
      "timestamp": DateTime.now(),
    });
  }

  // fetch all messages from a chat subcollection
  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> fetchMessages(
      {required String receiver_id}) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshots =
        await db.collection("chatrooms").get();

    List<dynamic> users = [];
    String docId = "";

    querySnapshots.docs.forEach((DocumentSnapshot<Map<String, dynamic>> doc) {
      users = doc.data()?["users"] ?? []; // Use null check operator for safety
      if (users.contains(receiver_id) &&
          users.contains(AuthHelper.firebaseAuth.currentUser!.uid)) {
        // get doc id
        docId = doc.id;
      }
    });

    return db
        .collection("chatrooms")
        .doc(docId)
        .collection("chat")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }
}
