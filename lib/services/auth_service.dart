import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'notification_service.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _google = GoogleSignIn();
  final _db = FirebaseFirestore.instance;

  Stream<User?> authState() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await persistUserToken();
  }

  Future<void> signInWithGoogle() async {
    final account = await _google.signIn();
    if (account == null) {
      throw FirebaseAuthException(
        code: 'canceled',
        message: 'Google sign-in was canceled.',
      );
    }
    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
    await persistUserToken();
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  Future<void> persistUserToken() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final token = await NotificationService.instance.getToken();
    await _db.collection('users').doc(user.uid).set({
      'email': user.email,
      'displayName': user.displayName,
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
