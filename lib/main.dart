import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/navigation.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/task_list_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  final options = DefaultFirebaseOptions.currentPlatform;
  final placeholder = options.projectId == 'your-firebase-project-id' ||
      options.apiKey.startsWith('YOUR_');
  if (placeholder) {
    runApp(const FirebaseTaskApp(ready: false));
    return;
  }

  await Firebase.initializeApp(options: options);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.instance.initialize();
  unawaited(AuthService.instance.saveUserProfile());
  FirebaseMessaging.instance.onTokenRefresh.listen((_) {
    AuthService.instance.saveUserProfile();
  });

  runApp(const FirebaseTaskApp(ready: true));
}

class FirebaseTaskApp extends StatelessWidget {
  const FirebaseTaskApp({super.key, required this.ready});

  final bool ready;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Task Manager',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.key,
      theme: AppTheme.light(),
      home: ready ? const AuthGate() : const SetupScreen(),
      routes: {
        '/tasks': (_) => const TaskListScreen(),
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showSplash = true;
  bool _authReady = false;
  User? _user;
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    _user = AuthService.instance.currentUser;
    _authSub = AuthService.instance.authState.listen((user) {
      if (!mounted) return;
      setState(() {
        _user = user;
        _authReady = true;
      });
    });
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash || !_authReady && _user == null) {
      return const SplashScreen();
    }

    if (_user == null || AuthService.instance.suppressAuthNavigation) {
      return const LoginScreen(key: ValueKey('login'));
    }
    return const TaskListScreen(key: ValueKey('tasks'));
  }
}
