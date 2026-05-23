import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class TaskRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  TaskRepository({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Real-time task stream for current user
  Stream<List<Task>> tasksStream(String userId) {
    return _db
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final tasks = snap.docs
              .map((d) => Task.fromJson({...d.data(), 'id': d.id}))
              .toList();
          tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return tasks;
        });
  }

  Future<void> createTask(Task task) async {
    await _db.collection('tasks').add(task.toJson());
  }

  Future<void> updateTask(Task task) async {
    await _db.collection('tasks').doc(task.id).update(task.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  Future<void> toggleComplete(String taskId, bool isComplete) async {
    await _db.collection('tasks').doc(taskId).update({
      'status': isComplete ? 'done' : 'todo',
      'completedAt': isComplete ? DateTime.now().toIso8601String() : null,
    });
  }

  // Authentication Methods
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  Future<void> linkAccount(String email, String password) async {
    final credential = EmailAuthProvider.credential(email: email, password: password);
    await _auth.currentUser?.linkWithCredential(credential);
  }

  Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
