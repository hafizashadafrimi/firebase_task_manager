import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/task_item.dart';
import '../services/notification_service.dart';
import '../services/task_service.dart';
import '../widgets/priority_selector.dart';
import '../widgets/brand_mark.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.task});

  final TaskItem? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _course;
  late DateTime _dueDate;
  late TaskPriority _priority;
  late bool _completed;
  bool _saving = false;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = TextEditingController(text: task?.title ?? '');
    _description = TextEditingController(text: task?.description ?? '');
    _course = TextEditingController(text: task?.course ?? '');
    _dueDate = task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _priority = task?.priority ?? TaskPriority.medium;
    _completed = task?.completed ?? false;
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _course.dispose();
    super.dispose();
  }

  void _reset() {
    final task = widget.task;
    setState(() {
      _title.text = task?.title ?? '';
      _description.text = task?.description ?? '';
      _course.text = task?.course ?? '';
      _dueDate = task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
      _priority = task?.priority ?? TaskPriority.medium;
      _completed = task?.completed ?? false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await TaskService.instance.updateTask(
          widget.task!.copyWith(
            title: title,
            description: _description.text.trim(),
            dueDate: _dueDate,
            priority: _priority,
            completed: _completed,
            course: _course.text.trim(),
          ),
        );
      } else {
        final created = await TaskService.instance.createTask(
          title: title,
          description: _description.text.trim(),
          dueDate: _dueDate,
          priority: _priority,
          course: _course.text.trim(),
        );
        await NotificationService.instance.showTaskCreated(created);
      }
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Task' : 'New Task'),
        actions: [
          if (_isEdit)
            TextButton(
              onPressed: _reset,
              child: const Text('Reset'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Row(
            children: [
              const Expanded(child: FieldLabel('Title')),
              Text(
                '${_title.text.length}/100',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
          TextField(
            controller: _title,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: _isEdit ? 'Task title' : 'e.g. Complete Flutter Assignment',
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          FieldLabel(_isEdit ? 'Description & notes' : 'Notes'),
          TextField(
            controller: _description,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: _isEdit
                  ? 'Add details for this task'
                  : 'Add details, links, or notes',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Due date'),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(DateFormat('MM/dd/yyyy').format(_dueDate)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Course / Mark'),
                    TextField(
                      controller: _course,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(hintText: 'CS 421'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const FieldLabel('Priority'),
          PrioritySelector(
            value: _priority,
            onChanged: (value) => setState(() => _priority = value),
          ),
          if (_isEdit) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Completed',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                value: _completed,
                activeThumbColor: AppColors.primary,
                onChanged: (value) => setState(() => _completed = value),
              ),
            ),
          ],
          const SizedBox(height: 28),
          FilledButton(
            style: _isEdit
                ? FilledButton.styleFrom(backgroundColor: AppColors.ink)
                : null,
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isEdit ? Icons.check : Icons.add, size: 20),
                      const SizedBox(width: 8),
                      Text(_isEdit ? 'Save Changes' : 'Save Task'),
                    ],
                  ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.label)),
          ),
        ],
      ),
    );
  }
}
