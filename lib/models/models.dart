import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
abstract class AppUser with _$AppUser {
  factory AppUser({
    required String id,
    required String name,
    required String email,
  }) = _AppUser;
  
  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}

@freezed
abstract class Task with _$Task {
  factory Task({
    required String id,
    required String userId,
    required String title,
    String? description,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueDate,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _Task;
  
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get label => name[0].toUpperCase() + name.substring(1);
  
  Color get color {
    switch (this) {
      case TaskPriority.low:    return const Color(0xFF22C55E); // green
      case TaskPriority.medium: return const Color(0xFFF59E0B); // amber
      case TaskPriority.high:   return const Color(0xFFEF4444); // red
    }
  }
  
  IconData get icon {
    switch (this) {
      case TaskPriority.low:    return Icons.arrow_downward_rounded;
      case TaskPriority.medium: return Icons.remove_rounded;
      case TaskPriority.high:   return Icons.arrow_upward_rounded;
    }
  }
}

enum TaskStatus { todo, inProgress, done }

extension TaskStatusX on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:       return 'To Do';
      case TaskStatus.inProgress: return 'In Progress';
      case TaskStatus.done:       return 'Done';
    }
  }
  
  Color get color {
    switch (this) {
      case TaskStatus.todo:       return const Color(0xFF94A3B8); // slate
      case TaskStatus.inProgress: return const Color(0xFF3B82F6); // blue
      case TaskStatus.done:       return const Color(0xFF22C55E); // green
    }
  }
}
