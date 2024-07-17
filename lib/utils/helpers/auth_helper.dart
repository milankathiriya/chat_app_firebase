import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthHelper {
  AuthHelper._();
  static final AuthHelper authHelper = AuthHelper._();

  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  GoogleSignIn googleSignIn = GoogleSignIn();

  // anonymously sign in
  Future<Map<String, dynamic>> signInWithAnonymously() async {
    Map<String, dynamic> response = {};

    try {
      UserCredential userCredential = await firebaseAuth.signInAnonymously();

      User? user = userCredential.user;

      response["user"] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          response["error"] = "This authentication method is disabled...";
          break;
      }
    }

    return response;
  }

  // sign up (email & password)
  Future<Map<String, dynamic>> signUp(
      {required String email, required String password}) async {
    Map<String, dynamic> response = {};

    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      response["user"] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          response["error"] = "This email is already used by another user...";
          break;
        case "weak-password":
          response["error"] =
              "The password must be greater than 6 characters...";
          break;
        case "operation-not-allowed":
          response["error"] = "This authentication method is disabled...";
          break;
      }
    }

    return response;
  }

  // sign in (email & password)
  Future<Map<String, dynamic>> signIn(
      {required String email, required String password}) async {
    Map<String, dynamic> response = {};

    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      response["user"] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          response["error"] = "This user does not exists...";
          break;
        case "wrong-password":
          response["error"] = "Your password is wrong...";
          break;
        case "operation-not-allowed":
          response["error"] = "This authentication method is disabled...";
          break;
      }
    }

    return response;
  }

  // sign in with google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    Map<String, dynamic> response = {};

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);

      User? user = userCredential.user;

      response["user"] = user;
    } catch (e) {
      response["error"] = e;
    }

    return response;
  }

  // sign out
  Future<void> signOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }
}
