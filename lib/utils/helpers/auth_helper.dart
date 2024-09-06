import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_learning_app/utils/helpers/firestore_helper.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthHelper {
  AuthHelper._();
  static final AuthHelper authHelper = AuthHelper._();

  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();

  // sign_up
  Future<Map<String, dynamic>> signUpUser(
      {required String email, required String password}) async {
    Map<String, dynamic> res = {};

    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      res['user'] = user;

      await FirestoreHelper.firestoreHelper
          .addUser(email: user!.email!, uid: user!.uid);
    } on FirebaseAuthException catch (e) {
      res['error'] = "Sign Up failed since ${e.code}";
    }

    return res;
  }

  // sign_in
  Future<Map<String, dynamic>> signInUser(
      {required String email, required String password}) async {
    Map<String, dynamic> res = {};

    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      res['user'] = user;
    } on FirebaseAuthException catch (e) {
      res['error'] = "Sign In failed since ${e.code}";
    }

    return res;
  }

  // sign_in_with_google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    Map<String, dynamic> res = {};

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;

      res['user'] = user;

      await FirestoreHelper.firestoreHelper
          .addUser(email: user!.email!, uid: user!.uid);
    } catch (e) {
      res['error'] = "Sign In with Google failed...";
    }

    return res;
  }

  // sign_out
  Future<void> signOutUser() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }
}

// keytool -list -v -alias androiddebugkey -keystore C:\\users\\krish\\.android\\debug.keystore

// keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
