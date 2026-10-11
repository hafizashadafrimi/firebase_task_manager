import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/navigation.dart';
import '../core/theme.dart';
import '../models/task_item.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/task_service.dart';
import '../widgets/delete_task_dialog.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

enum TaskFilter { all, pending, completed }

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  TaskFilter _filter = TaskFilter.all;
  final _search = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    AppNavigator.pendingTaskId.addListener(_openPendingTask);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPendingTask());
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    AppNavigator.pendingTaskId.removeListener(_openPendingTask);
    _search.dispose();
    super.dispose();
  }

  Future<void> _openPendingTask() async {
    final id = AppNavigator.pendingTaskId.value;
    if (id == null || id.isEmpty || !mounted) return;
    AppNavigator.pendingTaskId.value = null;
    final task = await TaskService.instance.getTask(id);
    if (!mounted || task == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }

  Future<void> _openForm([TaskItem? task]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }

  Future<void> _delete(TaskItem task) async {
    final confirmed = await confirmDeleteTask(context, task);
    if (!confirmed) return;
    await TaskService.instance.deleteTask(task.id);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat("EEEE, MMM d").format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<TaskItem>>(
          stream: TaskService.instance.watchTasks(),
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? [];
            final query = _search.text.trim().toLowerCase();
            final visible = tasks.where((task) {
              final matchesFilter = switch (_filter) {
                TaskFilter.all => true,
                TaskFilter.pending => !task.completed,
                TaskFilter.completed => task.completed,
              };
              final matchesQuery = query.isEmpty ||
                  task.title.toLowerCase().contains(query) ||
                  task.description.toLowerCase().contains(query);
              return matchesFilter && matchesQuery;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _searching
                            ? TextField(
                                controller: _search,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: 'Search tasks',
                                  prefixIcon: Icon(Icons.search),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Tasks',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${tasks.length} TOTAL',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Today · $today',
                                    style: const TextStyle(color: AppColors.muted),
                                  ),
                                ],
                              ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _searching = !_searching;
                            if (!_searching) _search.clear();
                          });
                        },
                        icon: Icon(_searching ? Icons.close : Icons.search),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'logout') {
                            AuthService.instance.signOut();
                          } else if (value == 'token') {
                            final token =
                                await NotificationService.instance.getToken();
                            if (!context.mounted) return;
                            if (token == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('FCM token is not ready yet.'),
                                ),
                              );
                              return;
                            }
                            await Clipboard.setData(ClipboardData(text: token));
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('FCM token copied. Use it in Firebase Messaging.'),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'token',
                            child: Text('Copy FCM token'),
                          ),
                          PopupMenuItem(value: 'logout', child: Text('Sign out')),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _filter == TaskFilter.all,
                        onTap: () => setState(() => _filter = TaskFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Pending',
                        selected: _filter == TaskFilter.pending,
                        onTap: () => setState(() => _filter = TaskFilter.pending),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Completed',
                        selected: _filter == TaskFilter.completed,
                        onTap: () => setState(() => _filter = TaskFilter.completed),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData
                      ? const Center(child: CircularProgressIndicator())
                      : visible.isEmpty
                          ? const Center(
                              child: Text(
                                'No tasks yet.\nTap New Task to get started.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.label),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                              itemCount: visible.length,
                              itemBuilder: (context, index) {
                                final task = visible[index];
                                return TaskCard(
                                  task: task,
                                  onTap: () => _openForm(task),
                                  onToggle: () =>
                                      TaskService.instance.toggleCompleted(task),
                                  onDelete: () => _delete(task),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.label,
          ),
        ),
      ),
    );
  }
}
