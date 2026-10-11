import 'package:flutter/material.dart';

import '../core/theme.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: const [
              SizedBox(height: 24),
              Text(
                'Connect Firebase',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 12),
              Text(
                'The app is ready. Connect your own Firebase project, then run it again.',
                style: TextStyle(color: AppColors.label, height: 1.4),
              ),
              SizedBox(height: 24),
              _Step(
                number: '1',
                title: 'Create a Firebase project',
                body:
                    'Enable Authentication (Email/Password + Google), Cloud Firestore, and Cloud Messaging.',
              ),
              _Step(
                number: '2',
                title: 'Register the Android app',
                body:
                    'Package name: com.assignment.firebase_task_manager\nAdd your SHA-1 debug fingerprint for Google Sign-In.',
              ),
              _Step(
                number: '3',
                title: 'Generate config files',
                body:
                    'dart pub global activate flutterfire_cli\nflutterfire configure\nThis overwrites lib/firebase_options.dart and adds google-services.json / GoogleService-Info.plist.',
              ),
              _Step(
                number: '4',
                title: 'Firestore rules',
                body:
                    'Allow authenticated users to read/write users/{uid} and users/{uid}/tasks/{taskId}. See README.md.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.body});

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: AppColors.label, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
