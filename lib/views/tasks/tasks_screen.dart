import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../components/task_card.dart';
import '../../components/empty_state_view.dart';
import '../../app/theme.dart';
import 'create_task_sheet.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String _searchQuery = '';
  TaskStatus? _selectedFilter; // null means 'All'

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Tasks',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage and track your action items.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: IconButton(
                      icon: const Icon(Icons.account_circle_outlined, size: 28),
                      onPressed: () => context.push('/profile'),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  _buildFilterChip('All', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('To Do', TaskStatus.todo),
                  const SizedBox(width: 8),
                  _buildFilterChip('In Progress', TaskStatus.inProgress),
                  const SizedBox(width: 8),
                  _buildFilterChip('Done', TaskStatus.done),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: tasksAsync.when(
                data: (tasks) {
                  var filtered = tasks.where((t) {
                    if (_selectedFilter != null && t.status != _selectedFilter) return false;
                    if (_searchQuery.isNotEmpty && !t.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
                      return false;
                    }
                    return true;
                  }).toList();

                  // Sort by dueDate then priority
                  filtered.sort((a, b) {
                    if (a.dueDate != null && b.dueDate != null) {
                      final dateCompare = a.dueDate!.compareTo(b.dueDate!);
                      if (dateCompare != 0) return dateCompare;
                    } else if (a.dueDate != null) {
                      return -1;
                    } else if (b.dueDate != null) {
                      return 1;
                    }
                    return b.priority.index.compareTo(a.priority.index); // High > Medium > Low
                  });

                  if (filtered.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.search_off_rounded,
                      title: 'No tasks found',
                      subtitle: 'Try adjusting your filters or search query.',
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.only(bottom: 80), // padding for FAB
                    itemBuilder: (context, index) {
                      final task = filtered[index];
                      return Dismissible(
                        key: Key(task.id),
                        background: Container(
                          color: AppColors.success,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 24),
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: AppColors.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            // Delete
                            ref.read(taskViewModelProvider.notifier).deleteTask(task.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${task.title} deleted')),
                            );
                            return true; // We remove it optimistically from the list
                          } else {
                            // Complete toggle
                            final isComplete = task.status == TaskStatus.done;
                            ref.read(taskViewModelProvider.notifier).toggleComplete(task.id, !isComplete);
                            return false; // Don't remove from list, just update state
                          }
                        },
                        child: TaskCard(
                          task: task,
                          onTap: () => context.push('/tasks/${task.id}'),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateTaskSheet(),
              fullscreenDialog: true,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, TaskStatus? status) {
    final isSelected = _selectedFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = status);
        }
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Theme.of(context).textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
