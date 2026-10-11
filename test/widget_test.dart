import 'package:firebase_task_manager/main.dart';
import 'package:firebase_task_manager/screens/login_screen.dart';
import 'package:firebase_task_manager/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('shows Firebase setup screen before FlutterFire is configured',
      (tester) async {
    await tester.pumpWidget(const FirebaseTaskApp(ready: false));
    expect(find.text('Connect Firebase'), findsOneWidget);
  });

  testWidgets('splash shows assignment branding', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('Firebase Task Manager'), findsOneWidget);
    expect(find.textContaining('Flutter'), findsWidgets);
  });

  testWidgets('login has email, password, Google and Sign Up', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
