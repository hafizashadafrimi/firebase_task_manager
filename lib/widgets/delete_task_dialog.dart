import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/task_item.dart';

Future<bool> confirmDeleteTask(BuildContext context, TaskItem task) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.high.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.high,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Delete Task?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to remove this task? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.label, height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (task.course.isNotEmpty) ...[
                            _MiniChip(
                              label: task.course,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                          ],
                          _MiniChip(
                            label: task.priority.label,
                            color: switch (task.priority) {
                              TaskPriority.high => AppColors.high,
                              TaskPriority.medium => AppColors.medium,
                              TaskPriority.low => AppColors.low,
                            },
                          ),
                          if (task.completed) ...[
                            const SizedBox(width: 8),
                            const _MiniChip(label: 'Done', color: AppColors.low),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          task.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Due ${DateFormat('MMM d, y').format(task.dueDate)}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.high,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete Task'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.label),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
