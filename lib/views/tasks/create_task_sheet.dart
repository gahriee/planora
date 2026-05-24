import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import 'package:intl/intl.dart';

class CreateTaskSheet extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const CreateTaskSheet({super.key, this.initialDate});

  @override
  ConsumerState<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends ConsumerState<CreateTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _dueDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  FilledButton(
                    onPressed: () {
                      final title = _titleController.text.trim();
                      if (title.isEmpty) return;

                      final user = ref.read(authProvider).value;
                      if (user == null) return;

                      final task = Task(
                        id: const Uuid().v4(),
                        userId: user.id,
                        title: title,
                        description: _descController.text.trim(),
                        priority: _priority,
                        status: TaskStatus.todo,
                        dueDate: _dueDate,
                        createdAt: DateTime.now(),
                      );

                      ref.read(taskViewModelProvider.notifier).createTask(task);
                      Navigator.of(context).pop();
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _titleController,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'What needs to be done?',
                        border: InputBorder.none,
                        hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.3),
                        ),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descController,
                      decoration: InputDecoration(
                        hintText: 'Add more details...',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: 4,
                      minLines: 2,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Priority',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildPriorityCard(TaskPriority.low),
                        _buildPriorityCard(TaskPriority.medium),
                        _buildPriorityCard(TaskPriority.high),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Due Date',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => _dueDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _dueDate != null 
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) 
                              : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _dueDate != null 
                                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) 
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _dueDate != null 
                                    ? Theme.of(context).colorScheme.primary 
                                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.calendar_today, 
                                color: _dueDate != null ? Colors.white : Theme.of(context).iconTheme.color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected Date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _dueDate != null ? Theme.of(context).colorScheme.primary : null,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _dueDate == null ? 'Not set' : DateFormat('EEEE, MMMM d, yyyy').format(_dueDate!),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: _dueDate != null ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_dueDate != null)
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => setState(() => _dueDate = null),
                                color: Theme.of(context).colorScheme.error,
                              )
                            else
                              const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityCard(TaskPriority p) {
    final isSelected = _priority == p;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = p),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(p.icon, color: isSelected ? Colors.white : Theme.of(context).iconTheme.color?.withValues(alpha: 0.5), size: 28),
              const SizedBox(height: 8),
              Text(
                p.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
