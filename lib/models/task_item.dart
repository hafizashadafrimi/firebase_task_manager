import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get value => name;

  String get label => switch (this) {
        TaskPriority.high => 'High',
        TaskPriority.medium => 'Medium',
        TaskPriority.low => 'Low',
      };

  static TaskPriority fromString(String? value) {
    return TaskPriority.values.firstWhere(
      (item) => item.name == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.completed,
    required this.createdAt,
    this.course = '',
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool completed;
  final DateTime createdAt;
  final String course;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority.value,
      'completed': completed,
      'createdAt': Timestamp.fromDate(createdAt),
      'course': course,
    };
  }

  factory TaskItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TaskItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priority: TaskPriorityX.fromString(data['priority'] as String?),
      completed: data['completed'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      course: data['course'] as String? ?? '',
    );
  }

  TaskItem copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? completed,
    String? course,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      createdAt: createdAt,
      course: course ?? this.course,
    );
  }
}
