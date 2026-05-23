import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../components/stat_card.dart';
import '../../components/task_card.dart';
import '../../components/empty_state_view.dart';
import '../../app/theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      body: SafeArea(
        child: tasksAsync.when(
          data: (tasks) {
            final todayCompleted = ref.watch(todayCompletedProvider);
            final weekCompleted = ref.watch(weekCompletedProvider);
            final overdue = ref.watch(overdueTasksProvider);

            final completedTasks = tasks.where((t) => t.status == TaskStatus.done).toList();
            final completionRate = tasks.isEmpty ? 0.0 : completedTasks.length / tasks.length;

            final lowCount = tasks.where((t) => t.priority == TaskPriority.low).length;
            final mediumCount = tasks.where((t) => t.priority == TaskPriority.medium).length;
            final highCount = tasks.where((t) => t.priority == TaskPriority.high).length;

            final recentCompletions = completedTasks
                .where((t) => t.completedAt != null)
                .toList()
              ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
            
            final recent5 = recentCompletions.take(5).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Dashboard',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Here is an overview of your productivity.',
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
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (tasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 48.0),
                      child: EmptyStateView(
                        icon: Icons.dashboard_outlined,
                        title: 'No Tasks Yet',
                        subtitle: 'Your dashboard will populate once you add tasks.',
                      ),
                    )
                  else ...[
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.15,
                      children: [
                        StatCard(
                          title: 'Total Tasks',
                          value: tasks.length,
                          icon: Icons.task_alt,
                          color: AppColors.primary,
                        ),
                        StatCard(
                          title: 'Completed Today',
                          value: todayCompleted.length,
                          icon: Icons.today,
                          color: AppColors.success,
                        ),
                        StatCard(
                          title: 'Completed This Week',
                          value: weekCompleted.length,
                          icon: Icons.date_range,
                          color: AppColors.secondary,
                        ),
                        StatCard(
                          title: 'Overdue',
                          value: overdue.length,
                          icon: Icons.warning_amber_rounded,
                          color: AppColors.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Completion Rate',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: completionRate),
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 12,
                                    backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  '${(value * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Priority Breakdown',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildPriorityStat(context, 'Low', lowCount, TaskPriority.low.color)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPriorityStat(context, 'Medium', mediumCount, TaskPriority.medium.color)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPriorityStat(context, 'High', highCount, TaskPriority.high.color)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Recent Completions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (recent5.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No recent completions.'),
                      )
                    else
                      ...recent5.map((task) => TaskCard(task: task)),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildPriorityStat(BuildContext context, String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
