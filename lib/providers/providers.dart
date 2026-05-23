import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/task_repository.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/task_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/calendar_viewmodel.dart';

// ── Repositories ──
final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepository());

// ── Auth ──
final authProvider = StreamNotifierProvider<AuthViewModel, AppUser?>(() {
  return AuthViewModel();
});

// ── Tasks Stream ──
final tasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  final user = ref.watch(authProvider).value;
  if (user == null) return Stream.value([]);
  return ref.read(taskRepositoryProvider).tasksStream(user.id);
});

// ── ViewModels ──
final taskViewModelProvider = AsyncNotifierProvider<TaskViewModel, void>(() {
  return TaskViewModel();
});

final dashboardViewModelProvider = NotifierProvider<DashboardViewModel, void>(() {
  return DashboardViewModel();
});

final calendarViewModelProvider = NotifierProvider<CalendarViewModel, void>(() {
  return CalendarViewModel();
});

// ── Calendar Derived State ──
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();
  void setDate(DateTime date) => state = date;
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(() {
  return SelectedDateNotifier();
});

final selectedDateTasksProvider = Provider.autoDispose<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final date = ref.watch(selectedDateProvider);
  return tasks.where((t) =>
    t.dueDate != null &&
    t.dueDate!.year == date.year &&
    t.dueDate!.month == date.month &&
    t.dueDate!.day == date.day
  ).toList();
});

// ── Dashboard Derived State ──
final todayCompletedProvider = Provider.autoDispose<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final today = DateTime.now();
  return tasks.where((t) =>
    t.status == TaskStatus.done &&
    t.completedAt != null &&
    t.completedAt!.year == today.year &&
    t.completedAt!.month == today.month &&
    t.completedAt!.day == today.day
  ).toList();
});

final weekCompletedProvider = Provider.autoDispose<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 7));
  return tasks.where((t) =>
    t.status == TaskStatus.done &&
    t.completedAt != null &&
    t.completedAt!.isAfter(weekStart) &&
    t.completedAt!.isBefore(weekEnd)
  ).toList();
});

final pendingTasksProvider = Provider.autoDispose<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  return tasks.where((t) => t.status != TaskStatus.done).toList();
});

final overdueTasksProvider = Provider.autoDispose<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final now = DateTime.now();
  return tasks.where((t) =>
    t.status != TaskStatus.done &&
    t.dueDate != null &&
    t.dueDate!.isBefore(now)
  ).toList();
});
