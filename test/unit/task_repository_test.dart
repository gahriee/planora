import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planora/models/models.dart';
import 'package:planora/repositories/task_repository.dart';

void main() {
  group('TaskRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late TaskRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      final mockUser = MockUser(
        isAnonymous: false,
        uid: 'test_user_id',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      mockAuth = MockFirebaseAuth(mockUser: mockUser);
      repository = TaskRepository(db: fakeFirestore, auth: mockAuth);
    });

    group('Authentication', () {
      test('signInAnonymously sets current user', () async {
        final auth = MockFirebaseAuth();
        final repo = TaskRepository(db: fakeFirestore, auth: auth);
        
        await repo.signInAnonymously();
        expect(auth.currentUser, isNotNull);
        expect(auth.currentUser!.isAnonymous, isTrue);
      });

      test('login successfully signs in user', () async {
        final auth = MockFirebaseAuth(mockUser: MockUser(uid: 'login_user'));
        final repo = TaskRepository(db: fakeFirestore, auth: auth);
        
        await repo.login('test@example.com', 'password');
        expect(auth.currentUser, isNotNull);
        expect(auth.currentUser!.uid, 'login_user');
      });

      test('logout signs out current user', () async {
        await mockAuth.signInWithCustomToken('token');
        expect(mockAuth.currentUser, isNotNull);
        
        await repository.logout();
        expect(mockAuth.currentUser, isNull);
      });
    });

    group('Task CRUD', () {
      test('createTask adds a task to Firestore', () async {
        final task = Task(
          id: '',
          userId: 'test_user_id',
          title: 'New Task',
          createdAt: DateTime(2023, 1, 1),
          status: TaskStatus.todo,
          priority: TaskPriority.medium,
        );

        await repository.createTask(task);

        final snapshot = await fakeFirestore.collection('tasks').get();
        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['title'], 'New Task');
        expect(snapshot.docs.first.data()['userId'], 'test_user_id');
      });

      test('updateTask modifies existing task', () async {
        final docRef = await fakeFirestore.collection('tasks').add({
          'userId': 'test_user_id',
          'title': 'Old Title',
          'createdAt': DateTime(2023, 1, 1).toIso8601String(),
          'status': 'todo',
          'priority': 'medium',
        });

        final updatedTask = Task(
          id: docRef.id,
          userId: 'test_user_id',
          title: 'New Title',
          createdAt: DateTime(2023, 1, 1),
          status: TaskStatus.inProgress,
          priority: TaskPriority.high,
        );

        await repository.updateTask(updatedTask);

        final snapshot = await docRef.get();
        expect(snapshot.data()!['title'], 'New Title');
        expect(snapshot.data()!['status'], 'inProgress');
      });

      test('deleteTask removes task from Firestore', () async {
        final docRef = await fakeFirestore.collection('tasks').add({
          'userId': 'test_user_id',
          'title': 'To Delete',
        });

        await repository.deleteTask(docRef.id);

        final snapshot = await fakeFirestore.collection('tasks').doc(docRef.id).get();
        expect(snapshot.exists, isFalse);
      });

      test('toggleComplete updates status and completedAt', () async {
        final docRef = await fakeFirestore.collection('tasks').add({
          'userId': 'test_user_id',
          'title': 'Toggle Me',
          'status': 'todo',
        });

        // Toggle to complete
        await repository.toggleComplete(docRef.id, true);
        
        var snapshot = await docRef.get();
        var updatedData = snapshot.data()!;
        expect(updatedData['status'], 'done');
        expect(updatedData['completedAt'], isNotNull);
        expect(updatedData['completedAt'], isA<String>());

        // Toggle to incomplete
        await repository.toggleComplete(docRef.id, false);
        
        snapshot = await docRef.get();
        expect(snapshot.data()!['status'], 'todo');
        expect(snapshot.data()!['completedAt'], isNull);
      });

      test('tasksStream injects ID and filters by userId', () async {
        // Add one task for test user
        final docRef1 = await fakeFirestore.collection('tasks').add({
          'userId': 'test_user_id',
          'title': 'Test User Task',
          'createdAt': DateTime(2023, 1, 1).toIso8601String(),
          'status': 'todo',
          'priority': 'medium',
        });

        // Add one task for another user
        await fakeFirestore.collection('tasks').add({
          'userId': 'other_user_id',
          'title': 'Other User Task',
          'createdAt': DateTime(2023, 1, 1).toIso8601String(),
          'status': 'todo',
          'priority': 'medium',
        });

        final stream = repository.tasksStream('test_user_id');
        final tasksList = await stream.first;

        expect(tasksList.length, 1);
        expect(tasksList.first.id, docRef1.id); // ID should be injected
        expect(tasksList.first.title, 'Test User Task');
      });
    });
  });
}
