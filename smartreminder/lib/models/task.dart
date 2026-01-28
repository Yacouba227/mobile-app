import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final TaskCategory category;
  final TaskPriority priority;
  final DateTime? deadline;
  final Duration? estimatedDuration;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int completionCount;
  final int postponeCount;
  final List<DateTime> postponementHistory;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    this.deadline,
    this.estimatedDuration,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.completionCount = 0,
    this.postponeCount = 0,
    this.postponementHistory = const [],
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? deadline,
    Duration? estimatedDuration,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? completionCount,
    int? postponeCount,
    List<DateTime>? postponementHistory,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completionCount: completionCount ?? this.completionCount,
      postponeCount: postponeCount ?? this.postponeCount,
      postponementHistory: postponementHistory ?? this.postponementHistory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.index,
      'priority': priority.index,
      'deadline': deadline?.millisecondsSinceEpoch,
      'estimated_duration': estimatedDuration?.inSeconds,
      'status': status.index,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'completion_count': completionCount,
      'postpone_count': postponeCount,
      'postponement_history': postponementHistory
          .map((date) => date.millisecondsSinceEpoch.toString())
          .join(','),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: TaskCategory.values[map['category']],
      priority: TaskPriority.values[map['priority']],
      deadline: map['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deadline'])
          : null,
      estimatedDuration: map['estimated_duration'] != null
          ? Duration(seconds: map['estimated_duration'])
          : null,
      status: TaskStatus.values[map['status']],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      completionCount: map['completion_count'] ?? 0,
      postponeCount: map['postpone_count'] ?? 0,
      postponementHistory:
          (map['postponement_history'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .map((s) => DateTime.fromMillisecondsSinceEpoch(int.parse(s)))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    priority,
    deadline,
    estimatedDuration,
    status,
    createdAt,
    updatedAt,
    completionCount,
    postponeCount,
    postponementHistory,
  ];
}

enum TaskCategory {
  studies('Études', 0xFF6200EE),
  work('Travail', 0xFF03DAC6),
  personal('Personnel', 0xFFFF7043),
  leisure('Loisirs', 0xFFFFD600);

  final String displayName;
  final int colorValue;

  const TaskCategory(this.displayName, this.colorValue);
}

enum TaskPriority { low, medium, high }

extension TaskPriorityExtension on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Faible';
      case TaskPriority.medium:
        return 'Moyenne';
      case TaskPriority.high:
        return 'Élevée';
    }
  }

  int get value {
    switch (this) {
      case TaskPriority.low:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.high:
        return 3;
    }
  }
}

enum TaskStatus { pending, inProgress, completed, postponed }

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'En attente';
      case TaskStatus.inProgress:
        return 'En cours';
      case TaskStatus.completed:
        return 'Terminée';
      case TaskStatus.postponed:
        return 'Reportée';
    }
  }
}
