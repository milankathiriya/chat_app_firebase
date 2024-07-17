import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  FirestoreHelper._();
  static final FirestoreHelper firestoreHelper = FirestoreHelper._();

  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // TODO: insert UserModel object into users collection
  Future<void> insertUser() async {
    // await db.collection("users").add({"name": "Jay", "age": 20});  // auto-generate id
    await db.collection("users").doc("family").set({"name": "Jay", "age": 20});  // custom id
  }

  // TODO: update logged_in_at field UserModel object into users collection
}
