import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planora/models/models.dart';
import 'package:planora/providers/providers.dart';
import 'package:planora/views/dashboard/dashboard_screen.dart';

void main() {
  group('DashboardScreen Widget Tests', () {
    testWidgets('renders loading state initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => AsyncValue.data(
                  AppUser(id: '1', name: 'Test User', email: 'test@example.com'),
                ) as dynamic),
            tasksProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // We need to wait for the first frame
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('renders user greeting and dashboard metrics', (tester) async {
      final now = DateTime.now();
      final mockTasks = [
        // Pending task
        Task(
          id: 't1',
          userId: '1',
          title: 'Pending',
          createdAt: now,
          status: TaskStatus.todo,
          priority: TaskPriority.high,
        ),
        // Completed today
        Task(
          id: 't2',
          userId: '1',
          title: 'Done Today',
          createdAt: now,
          status: TaskStatus.done,
          priority: TaskPriority.medium,
          completedAt: now,
        ),
        // Overdue task
        Task(
          id: 't3',
          userId: '1',
          title: 'Overdue',
          createdAt: now.subtract(const Duration(days: 2)),
          dueDate: now.subtract(const Duration(days: 1)),
          status: TaskStatus.todo,
          priority: TaskPriority.low,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => AsyncValue.data(
                  AppUser(id: '1', name: 'Gary', email: 'gary@test.com'),
                ) as dynamic),
            tasksProvider.overrideWith((ref) => Stream.value(mockTasks)),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // Let the stream emit and providers compute
      await tester.pumpAndSettle();

      // Check StatCards values
      expect(find.text('3'), findsWidgets); // Total Tasks = 3
      expect(find.text('1'), findsWidgets); // Today completed = 1, Week = 1, Overdue = 1

      // Check completion rate progress (1 out of 3 = 33%)
      expect(find.text('33%'), findsOneWidget);

      // Check Recent Activity
      expect(find.text('Recent Completions'), findsOneWidget);
      expect(find.text('Done Today'), findsOneWidget);
    });
  });
}
