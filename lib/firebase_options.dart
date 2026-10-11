// Generated from Firebase project fir-task-manager-8d1eb
// Android app: com.assignment.firebase_task_manager

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBrvibGOigZ1CvhleCJpvNo33RnpmuVpWM',
    appId: '1:74676348038:android:a9bc797f0d29fe9daa1d07',
    messagingSenderId: '74676348038',
    projectId: 'fir-task-manager-8d1eb',
    authDomain: 'fir-task-manager-8d1eb.firebaseapp.com',
    storageBucket: 'fir-task-manager-8d1eb.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrvibGOigZ1CvhleCJpvNo33RnpmuVpWM',
    appId: '1:74676348038:android:a9bc797f0d29fe9daa1d07',
    messagingSenderId: '74676348038',
    projectId: 'fir-task-manager-8d1eb',
    storageBucket: 'fir-task-manager-8d1eb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBrvibGOigZ1CvhleCJpvNo33RnpmuVpWM',
    appId: '1:74676348038:android:a9bc797f0d29fe9daa1d07',
    messagingSenderId: '74676348038',
    projectId: 'fir-task-manager-8d1eb',
    storageBucket: 'fir-task-manager-8d1eb.firebasestorage.app',
    iosBundleId: 'com.assignment.firebaseTaskManager',
  );
}
