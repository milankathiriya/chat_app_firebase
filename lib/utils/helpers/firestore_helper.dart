import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_learning_app/utils/helpers/auth_helper.dart';
import 'package:firebase_learning_app/utils/helpers/local_push_notification_helper.dart';

class FirestoreHelper {
  FirestoreHelper._();
  static final FirestoreHelper firestoreHelper = FirestoreHelper._();

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // insert authenticated(signed-up) user
  Future<void> addUser({required String email, required String uid}) async {
    // check if a user already exists or not
    bool isUserExists = false;

    QuerySnapshot<Map<String, dynamic>> res =
        await firebaseFirestore.collection("users").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allUsers = res.docs;

    allUsers.forEach((QueryDocumentSnapshot<Map<String, dynamic>> user) {
      Map<String, dynamic> data = user.data();

      if (data['email'] == email) {
        isUserExists = true;
      }
    });

    if (isUserExists == false) {
      await firebaseFirestore.collection("users").add({
        "email": email,
        "uid": uid,
      });
    }
  }

  // fetch all users
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllUsers() {
    return firebaseFirestore.collection("users").snapshots();
  }

  // send message
  Future<void> sendMessage(
      {required String msg, required String receiver}) async {
    // check if a chatroom is already exists or not
    bool isChatroomExists = false;

    String senderEmail = AuthHelper.firebaseAuth.currentUser!.email!;

    QuerySnapshot<Map<String, dynamic>> res =
        await firebaseFirestore.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms = res.docs;

    String? chatroomId;

    allChatrooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      Map<String, dynamic> data = chatroom.data();

      List users = data['users'];

      if (users.contains(receiver) && users.contains(senderEmail)) {
        isChatroomExists = true;
        chatroomId = chatroom.id;
      }
    });

    if (isChatroomExists == false) {
      DocumentReference<Map<String, dynamic>> docRef =
          await firebaseFirestore.collection("chatrooms").add({
        "users": [
          receiver,
          senderEmail,
        ],
      });

      chatroomId = docRef.id;
    }

    // store message
    await firebaseFirestore
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .add({
      "msg": msg,
      "sender": senderEmail,
      "receiver": receiver,
      "timestamp": FieldValue.serverTimestamp(),
    });

    // send a notification
    await LocalPushNotificationHelper.localPushNotificationHelper
        .showSimpleNotification(sender: senderEmail, msg: msg);
  }

  // fetch all messages
  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> fetchAllMessages(
      {required String receiverEmail}) async {
    String senderEmail = AuthHelper.firebaseAuth.currentUser!.email!;

    QuerySnapshot<Map<String, dynamic>> res =
        await firebaseFirestore.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms = res.docs;

    String? chatroomId;

    allChatrooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      Map<String, dynamic> data = chatroom.data();

      List users = data['users'];

      if (users.contains(receiverEmail) && users.contains(senderEmail)) {
        chatroomId = chatroom.id;
      }
    });

    return firebaseFirestore
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }
}
