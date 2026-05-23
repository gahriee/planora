import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planora/models/models.dart';
import 'package:planora/providers/providers.dart';
import 'package:planora/views/tasks/tasks_screen.dart';

void main() {
  group('TasksScreen Widget Tests', () {
    testWidgets('renders all tasks and applies filters correctly', (tester) async {
      final now = DateTime.now();
      final mockTasks = [
        Task(
          id: 't1',
          userId: '1',
          title: 'Task To Do',
          createdAt: now,
          status: TaskStatus.todo,
          priority: TaskPriority.high,
        ),
        Task(
          id: 't2',
          userId: '1',
          title: 'Task In Progress',
          createdAt: now,
          status: TaskStatus.inProgress,
          priority: TaskPriority.medium,
        ),
        Task(
          id: 't3',
          userId: '1',
          title: 'Task Done',
          createdAt: now,
          status: TaskStatus.done,
          priority: TaskPriority.low,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value(mockTasks)),
          ],
          child: const MaterialApp(
            home: TasksScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially 'All' is selected, so all 3 tasks should be visible
      expect(find.text('Task To Do'), findsOneWidget);
      expect(find.text('Task In Progress'), findsOneWidget);
      expect(find.text('Task Done'), findsOneWidget);

      // Tap 'To Do' filter
      await tester.tap(find.widgetWithText(ChoiceChip, 'To Do'));
      await tester.pumpAndSettle();

      // Only To Do should be visible
      expect(find.text('Task To Do'), findsOneWidget);
      expect(find.text('Task In Progress'), findsNothing);
      expect(find.text('Task Done'), findsNothing);

      // Tap 'In Progress' filter
      await tester.tap(find.widgetWithText(ChoiceChip, 'In Progress'));
      await tester.pumpAndSettle();

      expect(find.text('Task In Progress'), findsOneWidget);
      expect(find.text('Task To Do'), findsNothing);
      
      // Clear search should have no effect since it's empty, but we can test search input
      await tester.enterText(find.byType(TextField), 'Done');
      await tester.pumpAndSettle();
      
      // In 'In Progress' tab, searching for 'Done' should yield empty
      expect(find.text('Task In Progress'), findsNothing);
      
      // Go back to 'All'
      await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
      await tester.pumpAndSettle();
      
      // Search is 'Done', so 'Task Done' should show up
      expect(find.text('Task Done'), findsOneWidget);
      expect(find.text('Task To Do'), findsNothing);
    });
  });
}
