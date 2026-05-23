import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  Task? _task;
  late TextEditingController _titleController;
  late TextEditingController _descController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onFieldChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _saveTask();
    });
  }

  void _saveTask() {
    if (_task == null) return;
    final updated = _task!.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
    );
    ref.read(taskViewModelProvider.notifier).updateTask(updated);
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return tasksAsync.when(
      data: (tasks) {
        final taskIndex = tasks.indexWhere((t) => t.id == widget.taskId);
        if (taskIndex == -1) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Task not found')),
          );
        }

        final task = tasks[taskIndex];
        
        if (_task == null) {
          _task = task;
          _titleController.text = task.title;
          _descController.text = task.description ?? '';
        } else {
            _task = task;
        }

        return Scaffold(
          appBar: AppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: FilledButton(
                  onPressed: () {
                    _saveTask();
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete Task', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (val) {
                  if (val == 'delete') {
                    ref.read(taskViewModelProvider.notifier).deleteTask(task.id);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _titleController,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: 'Task Title',
                    filled: false,
                  ),
                  onChanged: (_) => _onFieldChanged(),
                ),
                TextField(
                  controller: _descController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: 'Add description...',
                    filled: false,
                  ),
                  onChanged: (_) => _onFieldChanged(),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildSectionTitle(context, 'Status'),
                const SizedBox(height: 8),
                SegmentedButton<TaskStatus>(
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                    selectedForegroundColor: Colors.white,
                  ),
                  segments: const [
                    ButtonSegment(value: TaskStatus.todo, label: Text('To Do')),
                    ButtonSegment(value: TaskStatus.inProgress, label: Text('In Progress')),
                    ButtonSegment(value: TaskStatus.done, label: Text('Done')),
                  ],
                  selected: {task.status},
                  onSelectionChanged: (set) {
                    final status = set.first;
                    final updated = task.copyWith(
                      status: status,
                      completedAt: status == TaskStatus.done ? DateTime.now() : null,
                    );
                    ref.read(taskViewModelProvider.notifier).updateTask(updated);
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Priority'),
                const SizedBox(height: 8),
                SegmentedButton<TaskPriority>(
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                    selectedForegroundColor: Colors.white,
                  ),
                  segments: [
                    ButtonSegment(
                      value: TaskPriority.low,
                      label: const Text('Low'),
                      icon: Icon(TaskPriority.low.icon, color: TaskPriority.low.color),
                    ),
                    ButtonSegment(
                      value: TaskPriority.medium,
                      label: const Text('Medium'),
                      icon: Icon(TaskPriority.medium.icon, color: TaskPriority.medium.color),
                    ),
                    ButtonSegment(
                      value: TaskPriority.high,
                      label: const Text('High'),
                      icon: Icon(TaskPriority.high.icon, color: TaskPriority.high.color),
                    ),
                  ],
                  selected: {task.priority},
                  onSelectionChanged: (set) {
                    final updated = task.copyWith(priority: set.first);
                    ref.read(taskViewModelProvider.notifier).updateTask(updated);
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildSectionTitle(context, 'Due Date'),
                    const Spacer(),
                    InputChip(
                      label: Text(
                        task.dueDate == null ? 'Set Date' : DateFormat('MMM d, yyyy').format(task.dueDate!),
                      ),
                      avatar: const Icon(Icons.calendar_today, size: 16),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: task.dueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          ref.read(taskViewModelProvider.notifier).updateTask(task.copyWith(dueDate: date));
                        }
                      },
                      onDeleted: task.dueDate == null
                          ? null
                          : () {
                              ref.read(taskViewModelProvider.notifier).updateTask(task.copyWith(dueDate: null));
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
    );
  }
}
