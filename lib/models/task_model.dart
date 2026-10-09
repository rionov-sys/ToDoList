import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../core/utils/date_formatter.dart';

enum TaskStatus {
  TODO,
  IN_PROGRESS,
  COMPLETED,
  BLOCKED;

  String get label {
    switch (this) {
      case TaskStatus.TODO:
        return 'TO DO';
      case TaskStatus.IN_PROGRESS:
        return 'IN PROGRESS';
      case TaskStatus.COMPLETED:
        return 'COMPLETED';
      case TaskStatus.BLOCKED:
        return 'BLOCKED';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.TODO:
        return AppColors.todo;
      case TaskStatus.IN_PROGRESS:
        return AppColors.inProgress;
      case TaskStatus.COMPLETED:
        return AppColors.completed;
      case TaskStatus.BLOCKED:
        return AppColors.blocked;
    }
  }

  Color get containerColor {
    switch (this) {
      case TaskStatus.TODO:
        return AppColors.todoContainer;
      case TaskStatus.IN_PROGRESS:
        return AppColors.inProgressContainer;
      case TaskStatus.COMPLETED:
        return AppColors.completedContainer;
      case TaskStatus.BLOCKED:
        return AppColors.blockedContainer;
    }
  }

  IconData get icon {
    switch (this) {
      case TaskStatus.TODO:
        return Icons.radio_button_unchecked_rounded;
      case TaskStatus.IN_PROGRESS:
        return Icons.timelapse_rounded;
      case TaskStatus.COMPLETED:
        return Icons.check_circle_rounded;
      case TaskStatus.BLOCKED:
        return Icons.block_rounded;
    }
  }
}

enum TaskPriority {
  LOW,
  MEDIUM,
  HIGH,
  URGENT;

  String get label {
    switch (this) {
      case TaskPriority.LOW:
        return 'LOW';
      case TaskPriority.MEDIUM:
        return 'MEDIUM';
      case TaskPriority.HIGH:
        return 'HIGH';
      case TaskPriority.URGENT:
        return 'URGENT';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.LOW:
        return AppColors.completed;
      case TaskPriority.MEDIUM:
        return AppColors.inProgress;
      case TaskPriority.HIGH:
        return AppColors.secondary;
      case TaskPriority.URGENT:
        return AppColors.urgent;
    }
  }

  Color get containerColor {
    switch (this) {
      case TaskPriority.LOW:
        return AppColors.completedContainer;
      case TaskPriority.MEDIUM:
        return AppColors.inProgressContainer;
      case TaskPriority.HIGH:
        return AppColors.surfaceContainer;
      case TaskPriority.URGENT:
        return AppColors.urgentContainer;
    }
  }
}

class SubTaskModel {
  final String id;
  final String title;
  final bool isCompleted;

  const SubTaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubTaskModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory SubTaskModel.fromJson(Map<String, dynamic> json) {
    return SubTaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted,
    };
  }
}

class TaskModel {
  final String id;
  final String userId;
  final String categoryId;
  final String categoryName;
  final String categoryColorHex;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final int progressPercentage;
  final DateTime startTime;
  final DateTime dueTime;
  final DateTime? actualCompletedAt;
  final bool isRecurring;
  final String? recurrenceRule;
  final List<SubTaskModel> subtasks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPendingSync;

  const TaskModel({
    required this.id,
    required this.userId,
    this.categoryId = 'cat_1',
    this.categoryName = 'Work',
    this.categoryColorHex = '#4F46E5',
    required this.title,
    this.description = '',
    this.status = TaskStatus.TODO,
    this.priority = TaskPriority.MEDIUM,
    this.progressPercentage = 0,
    required this.startTime,
    required this.dueTime,
    this.actualCompletedAt,
    this.isRecurring = false,
    this.recurrenceRule,
    this.subtasks = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isPendingSync = false,
  });

  bool get isCompleted => status == TaskStatus.COMPLETED;
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(dueTime);

  int get completedSubtasksCount =>
      subtasks.where((s) => s.isCompleted).length;

  int get totalSubtasksCount => subtasks.length;

  String get timeRangeFormatted {
    return '${DateFormatter.formatTime(startTime)} - ${DateFormatter.formatTime(dueTime)}';
  }

  Color get categoryColor {
    try {
      final hex = categoryColorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primaryContainer;
    }
  }

  TaskModel copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? categoryName,
    String? categoryColorHex,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    int? progressPercentage,
    DateTime? startTime,
    DateTime? dueTime,
    DateTime? actualCompletedAt,
    bool? isRecurring,
    String? recurrenceRule,
    List<SubTaskModel>? subtasks,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPendingSync,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryColorHex: categoryColorHex ?? this.categoryColorHex,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      startTime: startTime ?? this.startTime,
      dueTime: dueTime ?? this.dueTime,
      actualCompletedAt: actualCompletedAt ?? this.actualCompletedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? 'user_1',
      categoryId: json['category_id'] as String? ?? 'cat_1',
      categoryName: json['category_name'] as String? ?? 'Work',
      categoryColorHex: json['category_color_hex'] as String? ?? '#4F46E5',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.TODO,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.MEDIUM,
      ),
      progressPercentage: (json['progress_percentage'] as num?)?.toInt() ?? 0,
      startTime: DateTime.parse(json['start_time'] as String),
      dueTime: DateTime.parse(json['due_time'] as String),
      actualCompletedAt: json['actual_completed_at'] != null
          ? DateTime.parse(json['actual_completed_at'] as String)
          : null,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurrenceRule: json['recurrence_rule'] as String?,
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((s) => SubTaskModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isPendingSync: json['is_pending_sync'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'category_name': categoryName,
      'category_color_hex': categoryColorHex,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'progress_percentage': progressPercentage,
      'start_time': startTime.toIso8601String(),
      'due_time': dueTime.toIso8601String(),
      'actual_completed_at': actualCompletedAt?.toIso8601String(),
      'is_recurring': isRecurring,
      'recurrence_rule': recurrenceRule,
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_pending_sync': isPendingSync,
    };
  }
}
