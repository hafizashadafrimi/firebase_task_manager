import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_item.dart';

class TaskService {
  TaskService._();
  static final instance = TaskService._();

  CollectionReference<Map<String, dynamic>> get _tasks {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Not signed in');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks');
  }

  Stream<List<TaskItem>> watchTasks() {
    return _tasks
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
    final now = DateTime.now();
    final doc = _tasks.doc();
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
    await doc.set(task.toMap());
    return task;
  }

  Future<void> updateTask(TaskItem task) {
    return _tasks.doc(task.id).update(task.toMap());
  }

  Future<void> toggleCompleted(TaskItem task) {
    return _tasks.doc(task.id).update({'completed': !task.completed});
  }

  Future<void> deleteTask(String id) {
    return _tasks.doc(id).delete();
  }

  Future<TaskItem?> getTask(String id) async {
    final doc = await _tasks.doc(id).get();
    if (!doc.exists) return null;
    return TaskItem.fromDoc(doc);
  }
}
