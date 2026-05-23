import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';

class AuthViewModel extends StreamNotifier<AppUser?> {
  @override
  Stream<AppUser?> build() {
    return ref.read(taskRepositoryProvider).authStateChanges().map((user) {
      if (user == null) return null;
      return AppUser(
        id: user.uid,
        name: user.displayName ?? 'Anonymous User',
        email: user.email ?? '',
      );
    });
  }

  Future<void> signInAnonymously() async {
    try {
      state = const AsyncLoading();
      await ref.read(taskRepositoryProvider).signInAnonymously();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = const AsyncLoading();
      await ref.read(taskRepositoryProvider).login(email, password);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> linkAccount(String email, String password) async {
    try {
      state = const AsyncLoading();
      await ref.read(taskRepositoryProvider).linkAccount(email, password);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      state = const AsyncLoading();
      await ref.read(taskRepositoryProvider).signUp(email, password);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    try {
      state = const AsyncLoading();
      await ref.read(taskRepositoryProvider).logout();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
