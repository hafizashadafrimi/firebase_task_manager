import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_item.dart';

class TaskService {
  TaskService._();
  static final instance = TaskService._();

  CollectionReference<Map<String, dynamic>> _taskCol(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks');
  }

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Not signed in');
    }
    return uid;
  }

  Stream<List<TaskItem>> watchTasks() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(const []);
    }
    return _taskCol(user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TaskItem.fromDoc).toList());
  }

  Future<TaskItem> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    String course = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }
    final now = DateTime.now();
    final doc = _taskCol(user.uid).doc();
    final task = TaskItem(
      id: doc.id,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      completed: false,
      createdAt: now,
      course: course,
    );
    await doc.set({
      ...task.toMap(),
      'userId': user.uid,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return task;
  }

  Future<void> updateTask(TaskItem task) {
    return _taskCol(_uid).doc(task.id).update(task.toMap());
  }

  Future<void> toggleCompleted(TaskItem task) {
    return _taskCol(_uid).doc(task.id).update({'completed': !task.completed});
  }

  Future<void> deleteTask(String id) {
    return _taskCol(_uid).doc(id).delete();
  }

  Future<TaskItem?> getTask(String id) async {
    final doc = await _taskCol(_uid).doc(id).get();
    if (!doc.exists) return null;
    return TaskItem.fromDoc(doc);
  }
}
