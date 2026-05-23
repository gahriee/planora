import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';

class TaskViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createTask(Task task) async {
    try {
      state = const AsyncLoading();
      await ref.read(taskRepositoryProvider).createTask(task);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      state = const AsyncLoading();
      await ref.read(taskRepositoryProvider).updateTask(task);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      state = const AsyncLoading();
      await ref.read(taskRepositoryProvider).deleteTask(taskId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleComplete(String taskId, bool isComplete) async {
    try {
      await ref.read(taskRepositoryProvider).toggleComplete(taskId, isComplete);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
