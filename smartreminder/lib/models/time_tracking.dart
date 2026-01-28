import 'package:equatable/equatable.dart';
import 'task.dart';

class TimeTrackingSession extends Equatable {
  final String id;
  final String taskId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final bool isCompleted;
  final List<Interruption> interruptions;

  const TimeTrackingSession({
    required this.id,
    required this.taskId,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.isCompleted = false,
    this.interruptions = const [],
  });

  TimeTrackingSession copyWith({
    String? id,
    String? taskId,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    bool? isCompleted,
    List<Interruption>? interruptions,
  }) {
    return TimeTrackingSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      interruptions: interruptions ?? this.interruptions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'duration': duration.inSeconds,
      'is_completed': isCompleted ? 1 : 0,
      'interruptions': interruptions.map((i) => i.toMap()).toList(),
    };
  }

  factory TimeTrackingSession.fromMap(Map<String, dynamic> map) {
    return TimeTrackingSession(
      id: map['id'],
      taskId: map['task_id'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time']),
      endTime: map['end_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_time'])
          : null,
      duration: Duration(seconds: map['duration']),
      isCompleted: map['is_completed'] == 1,
      interruptions:
          (map['interruptions'] as List<dynamic>?)
              ?.map((item) => Interruption.fromMap(item))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    taskId,
    startTime,
    endTime,
    duration,
    isCompleted,
    interruptions,
  ];
}

class Interruption extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final String? reason;

  const Interruption({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.reason,
  });

  Interruption copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    String? reason,
  }) {
    return Interruption(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      reason: reason ?? this.reason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'duration': duration.inSeconds,
      'reason': reason,
    };
  }

  factory Interruption.fromMap(Map<String, dynamic> map) {
    return Interruption(
      id: map['id'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time']),
      endTime: map['end_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_time'])
          : null,
      duration: Duration(seconds: map['duration']),
      reason: map['reason'],
    );
  }

  @override
  List<Object?> get props => [id, startTime, endTime, duration, reason];
}

class AnalyticsData {
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<TaskCategory, Duration> timeByCategory;
  final List<TopTask> topTimeConsumingTasks;
  final List<TopTask> mostPostponedTasks;
  final Map<int, Duration> timeByHour; // Hour -> Total time spent
  final int totalTasksCompleted;
  final Duration totalTimeSpent;
  final double productivityScore; // 0-100

  const AnalyticsData({
    required this.periodStart,
    required this.periodEnd,
    required this.timeByCategory,
    required this.topTimeConsumingTasks,
    required this.mostPostponedTasks,
    required this.timeByHour,
    required this.totalTasksCompleted,
    required this.totalTimeSpent,
    required this.productivityScore,
  });

  AnalyticsData copyWith({
    DateTime? periodStart,
    DateTime? periodEnd,
    Map<TaskCategory, Duration>? timeByCategory,
    List<TopTask>? topTimeConsumingTasks,
    List<TopTask>? mostPostponedTasks,
    Map<int, Duration>? timeByHour,
    int? totalTasksCompleted,
    Duration? totalTimeSpent,
    double? productivityScore,
  }) {
    return AnalyticsData(
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      timeByCategory: timeByCategory ?? this.timeByCategory,
      topTimeConsumingTasks:
          topTimeConsumingTasks ?? this.topTimeConsumingTasks,
      mostPostponedTasks: mostPostponedTasks ?? this.mostPostponedTasks,
      timeByHour: timeByHour ?? this.timeByHour,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      productivityScore: productivityScore ?? this.productivityScore,
    );
  }
}

class TopTask {
  final String taskId;
  final String taskTitle;
  final Duration value; // Time spent or postponement count
  final TaskCategory category;

  const TopTask({
    required this.taskId,
    required this.taskTitle,
    required this.value,
    required this.category,
  });
}
