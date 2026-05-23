import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:planora/models/models.dart';
import 'package:planora/providers/providers.dart';
import 'package:planora/repositories/task_repository.dart';
import '../helpers/test_helpers.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  group('AuthViewModel', () {
    late MockTaskRepository mockRepository;
    late StreamController<MockUser?> authStreamController;

    setUp(() {
      mockRepository = MockTaskRepository();
      authStreamController = StreamController<MockUser?>();
      when(() => mockRepository.authStateChanges()).thenAnswer((_) => authStreamController.stream);
    });

    tearDown(() {
      authStreamController.close();
    });

    test('build method correctly sets state based on authStateChanges', () async {
      final container = createContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      
      // Wait for build to complete
      await Future.microtask(() {});

      // Initially stream emits nothing, state should be loading (as StreamNotifier is listening to the stream)
      expect(container.read(authProvider), isA<AsyncLoading<AppUser?>>());

      // Emit a user
      authStreamController.add(MockUser(uid: 'user_1', email: 'test@example.com'));
      
      // Let stream propagate
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(authProvider);
      expect(state.value, isNotNull);
      expect(state.value!.id, 'user_1');
      expect(state.value!.email, 'test@example.com');
      
      // Emit null
      authStreamController.add(null);
      // Let stream propagate
      await Future.delayed(const Duration(milliseconds: 10));
      expect(container.read(authProvider).value, isNull);
    });

    test('signInAnonymously sets state to loading then delegates to repository', () async {
      when(() => mockRepository.signInAnonymously()).thenAnswer((_) async {});
      
      final container = createContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final authViewModel = container.read(authProvider.notifier);
      
      final future = authViewModel.signInAnonymously();
      
      expect(container.read(authProvider), isA<AsyncLoading>());
      
      await future;
      
      verify(() => mockRepository.signInAnonymously()).called(1);
    });

    test('login delegates to repository', () async {
      when(() => mockRepository.login(any(), any())).thenAnswer((_) async {});
      
      final container = createContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final authViewModel = container.read(authProvider.notifier);
      await authViewModel.login('test@example.com', 'password');
      
      verify(() => mockRepository.login('test@example.com', 'password')).called(1);
    });

    test('login catches error and sets AsyncError', () async {
      final error = Exception('Login Failed');
      when(() => mockRepository.login(any(), any())).thenThrow(error);
      
      final container = createContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final authViewModel = container.read(authProvider.notifier);
      await authViewModel.login('test@example.com', 'password');
      
      expect(container.read(authProvider), isA<AsyncError>());
      expect(container.read(authProvider).error, error);
    });
  });
}
