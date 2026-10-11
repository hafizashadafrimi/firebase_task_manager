import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/task_item.dart';

class PrioritySelector extends StatelessWidget {
  const PrioritySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TaskPriority value;
  final ValueChanged<TaskPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskPriority.values.map((priority) {
        final selected = priority == value;
        final color = switch (priority) {
          TaskPriority.low => AppColors.low,
          TaskPriority.medium => AppColors.medium,
          TaskPriority.high => AppColors.high,
        };
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: priority == TaskPriority.high ? 0 : 8,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => onChanged(priority),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? color.withValues(alpha: 0.14) : AppColors.field,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selected ? color : Colors.transparent,
                    width: 1.4,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selected)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.check, size: 16, color: color),
                      ),
                    Text(
                      priority.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? color : AppColors.label,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
