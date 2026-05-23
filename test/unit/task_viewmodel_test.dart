import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planora/models/models.dart';
import 'package:planora/providers/providers.dart';
import 'package:planora/repositories/task_repository.dart';
import '../helpers/test_helpers.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

// A fake class to allow fallback values for Any() in Mocktail
class FakeTask extends Fake implements Task {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTask());
  });

  group('TaskViewModel', () {
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
    });

    test('createTask calls repository and manages state', () async {
      when(() => mockRepository.createTask(any())).thenAnswer((_) async {});
      
      final container = createContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final viewModel = container.read(taskViewModelProvider.notifier);
      
      final task = Task(
        id: '',
        userId: 'u1',
        title: 'New',
        createdAt: DateTime.now(),
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
      );

      final future = viewModel.createTask(task);
      expect(container.read(taskViewModelProvider), isA<AsyncLoading>());
      
      await future;
      
      verify(() => mockRepository.createTask(task)).called(1);
      expect(container.read(taskViewModelProvider), isA<AsyncData>());
    });

    test('createTask sets error state on exception', () async {
      final error = Exception('Failed to create');
      when(() => mockRepository.createTask(any())).thenThrow(error);
      
      final container = createContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final viewModel = container.read(taskViewModelProvider.notifier);
      
      final task = Task(
        id: '',
        userId: 'u1',
        title: 'New',
        createdAt: DateTime.now(),
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
      );

      await viewModel.createTask(task);
      
      final state = container.read(taskViewModelProvider);
      expect(state, isA<AsyncError>());
      expect(state.error, error);
    });

    test('updateTask calls repository and manages state', () async {
      when(() => mockRepository.updateTask(any())).thenAnswer((_) async {});
      
      final container = createContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final viewModel = container.read(taskViewModelProvider.notifier);
      
      final task = Task(
        id: '1',
        userId: 'u1',
        title: 'Updated',
        createdAt: DateTime.now(),
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
      );

      final future = viewModel.updateTask(task);
      expect(container.read(taskViewModelProvider), isA<AsyncLoading>());
      
      await future;
      
      verify(() => mockRepository.updateTask(task)).called(1);
      expect(container.read(taskViewModelProvider), isA<AsyncData>());
    });

    test('deleteTask calls repository and manages state', () async {
      when(() => mockRepository.deleteTask(any())).thenAnswer((_) async {});
      
      final container = createContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final viewModel = container.read(taskViewModelProvider.notifier);
      
      final future = viewModel.deleteTask('task_1');
      expect(container.read(taskViewModelProvider), isA<AsyncLoading>());
      
      await future;
      
      verify(() => mockRepository.deleteTask('task_1')).called(1);
      expect(container.read(taskViewModelProvider), isA<AsyncData>());
    });

    test('toggleComplete calls repository', () async {
      when(() => mockRepository.toggleComplete(any(), any())).thenAnswer((_) async {});
      
      final container = createContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final viewModel = container.read(taskViewModelProvider.notifier);
      
      await viewModel.toggleComplete('task_1', true);
      
      verify(() => mockRepository.toggleComplete('task_1', true)).called(1);
    });
  });
}
