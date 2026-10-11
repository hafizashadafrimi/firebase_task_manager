import 'package:flutter/material.dart';

class AppNavigator {
  static final key = GlobalKey<NavigatorState>();
  static final pendingTaskId = ValueNotifier<String?>(null);

  static void openTask(String? taskId) {
    key.currentState?.popUntil((route) => route.isFirst);
    if (taskId == null || taskId.isEmpty) return;
    pendingTaskId.value = taskId;
  }
}
