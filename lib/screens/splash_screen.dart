import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/brand_mark.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(),
              const BrandMark(size: 88),
              const SizedBox(height: 28),
              const Text(
                'Firebase Task Manager',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'A simple task manager powered by Flutter\n& Firebase',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.label, height: 1.45),
              ),
              const Spacer(),
              const Text(
                'POWERED BY',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'FLUTTER  ·  FIREBASE',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
