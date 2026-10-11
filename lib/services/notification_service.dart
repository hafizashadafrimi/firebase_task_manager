import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/navigation.dart';
import '../firebase_options.dart';
import '../models/task_item.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background FCM: ${message.messageId} ${message.data}');
}

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'task_alerts',
    'Task alerts',
    description: 'Task manager push and local notifications',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _local.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        AppNavigator.openTask(response.payload);
      },
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      AppNavigator.openTask(_taskIdFrom(message));
    });

    final opened = await _local.getNotificationAppLaunchDetails();
    if (opened?.didNotificationLaunchApp == true) {
      AppNavigator.pendingTaskId.value =
          opened!.notificationResponse?.payload;
    }

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      AppNavigator.pendingTaskId.value = _taskIdFrom(initial);
    }
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'New Task';
    final body = message.notification?.body ??
        message.data['body'] ??
        'You have a new task';
    final taskId = _taskIdFrom(message);
    final priority =
        TaskPriorityX.fromString(message.data['priority'] as String?);

    await show(
      title: title,
      body: body,
      payload: taskId,
      priority: priority,
    );
  }

  Future<void> showTaskCreated(TaskItem task) {
    return show(
      title: 'New Task',
      body: 'You have a new task: ${task.title}',
      payload: task.id,
      priority: task.priority,
    );
  }

  Future<void> show({
    required String title,
    required String body,
    String? payload,
    TaskPriority priority = TaskPriority.medium,
  }) {
    final color = switch (priority) {
      TaskPriority.high => const Color(0xFFEF4444),
      TaskPriority.medium => const Color(0xFFF59E0B),
      TaskPriority.low => const Color(0xFF22C55E),
    };

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: switch (priority) {
          TaskPriority.high => Priority.max,
          TaskPriority.medium => Priority.high,
          TaskPriority.low => Priority.defaultPriority,
        },
        color: color,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    );

    return _local.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  String? _taskIdFrom(RemoteMessage message) {
    return message.data['taskId'] as String? ??
        message.data['task_id'] as String?;
  }
}
