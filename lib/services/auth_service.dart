import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'notification_service.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _google = GoogleSignIn();
  final _db = FirebaseFirestore.instance;

  Stream<User?> get authState => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// True while creating an account so AuthGate stays on login.
  bool suppressAuthNavigation = false;

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await saveUserProfile();
  }

  Future<void> signUpWithEmail(String email, String password) async {
    suppressAuthNavigation = true;
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await saveUserProfile();
      await _auth.signOut();
    } finally {
      suppressAuthNavigation = false;
    }
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
    await saveUserProfile();
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    // Firebase first so the UI switches to login immediately.
    await _auth.signOut();
    try {
      await _google.signOut();
    } catch (error) {
      debugPrint('Google signOut: $error');
    }
  }

  Future<void> saveUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? user.email?.split('@').first,
      'provider': user.providerData.isEmpty
          ? 'password'
          : user.providerData.first.providerId,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _saveFcmToken(user.uid);
  }

  Future<void> persistUserToken() => saveUserProfile();

  void _saveFcmToken(String uid) {
    NotificationService.instance.getToken().then((token) async {
      if (token == null || _auth.currentUser?.uid != uid) return;
      await _db.collection('users').doc(uid).set({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }).catchError((error) {
      debugPrint('FCM token save skipped: $error');
    });
  }
}
