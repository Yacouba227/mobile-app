import '../models/task.dart';
import '../models/time_tracking.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class TaskRepository {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  // Task operations
  Future<String> createTask(Task task) async {
    final taskId = await _dbService.insertTask(task);
    if (task.deadline != null) {
      try {
        await _notificationService.scheduleTaskReminder(task);
      } catch (e) {
        print('Warning: Could not schedule notification: $e');
        // Continue anyway, task was saved successfully
      }
    }
    return taskId;
  }

  Future<List<Task>> getAllTasks() async {
    return await _dbService.getAllTasks();
  }

  Future<List<Task>> getPendingTasks() async {
    return await _dbService.getTasksByStatus(TaskStatus.pending);
  }

  Future<List<Task>> getInProgressTasks() async {
    return await _dbService.getTasksByStatus(TaskStatus.inProgress);
  }

  Future<List<Task>> getCompletedTasks() async {
    return await _dbService.getTasksByStatus(TaskStatus.completed);
  }

  Future<List<Task>> getPostponedTasks() async {
    return await _dbService.getTasksByStatus(TaskStatus.postponed);
  }

  Future<List<Task>> getTasksByCategory(TaskCategory category) async {
    return await _dbService.getTasksByCategory(category);
  }

  Future<Task?> getTaskById(String id) async {
    return await _dbService.getTaskById(id);
  }

  Future<void> updateTask(Task task) async {
    await _dbService.updateTask(task);
    // Cancel existing notifications and schedule new ones
    try {
      await _notificationService.cancelTaskReminder(task.id);
      if (task.deadline != null) {
        await _notificationService.scheduleTaskReminder(task);
      }
    } catch (e) {
      print('Warning: Could not update notifications: $e');
      // Continue anyway
    }
  }

  Future<void> deleteTask(String id) async {
    await _dbService.deleteTask(id);
    await _notificationService.cancelTaskReminder(id);
  }

  Future<void> markTaskAsCompleted(String taskId) async {
    final task = await getTaskById(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(
        status: TaskStatus.completed,
        completionCount: task.completionCount + 1,
        updatedAt: DateTime.now(),
      );
      await updateTask(updatedTask);
    }
  }

  Future<void> markTaskAsInProgress(String taskId) async {
    final task = await getTaskById(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(
        status: TaskStatus.inProgress,
        updatedAt: DateTime.now(),
      );
      await updateTask(updatedTask);
    }
  }

  Future<void> postponeTask(String taskId) async {
    final task = await getTaskById(taskId);
    if (task != null) {
      final now = DateTime.now();
      final updatedTask = task.copyWith(
        status: TaskStatus.postponed,
        postponeCount: task.postponeCount + 1,
        postponementHistory: [...task.postponementHistory, now],
        updatedAt: now,
      );
      await updateTask(updatedTask);
    }
  }

  // Statistics and analytics
  Future<int> getTaskCountByStatus(TaskStatus status) async {
    final tasks = await _dbService.getTasksByStatus(status);
    return tasks.length;
  }

  Future<int> getTotalTaskCount() async {
    final tasks = await getAllTasks();
    return tasks.length;
  }

  Future<double> getCompletionRate() async {
    final totalTasks = await getTotalTaskCount();
    if (totalTasks == 0) return 0.0;

    final completedTasks = await getTaskCountByStatus(TaskStatus.completed);
    return (completedTasks / totalTasks) * 100;
  }

  Future<List<Task>> getMostPostponedTasks(int limit) async {
    final tasks = await getAllTasks();
    tasks.sort((a, b) => b.postponeCount.compareTo(a.postponeCount));
    return tasks.take(limit).toList();
  }

  Future<Map<TaskCategory, int>> getTaskCountByCategory() async {
    final counts = <TaskCategory, int>{};
    for (var category in TaskCategory.values) {
      final tasks = await getTasksByCategory(category);
      counts[category] = tasks.length;
    }
    return counts;
  }
}

class TimeTrackingRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<String> startTimeTracking(String taskId) async {
    final session = TimeTrackingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: taskId,
      startTime: DateTime.now(),
      duration: Duration.zero,
    );
    return await _dbService.insertTimeTrackingSession(session);
  }

  Future<void> stopTimeTracking(String sessionId) async {
    final session = await _dbService.getTimeTrackingSessionsByTask(
      sessionId.split('_').first,
    ); // Extract task ID

    if (session.isNotEmpty) {
      final lastSession = session.first;
      final endTime = DateTime.now();
      final duration = endTime.difference(lastSession.startTime);

      final updatedSession = lastSession.copyWith(
        endTime: endTime,
        duration: duration,
        isCompleted: true,
      );
      await _dbService.updateTimeTrackingSession(updatedSession);
    }
  }

  Future<void> addInterruption(String sessionId, String? reason) async {
    // Implementation for adding interruptions
    // This would require modifying the database service to handle interruptions properly
  }

  Future<List<TimeTrackingSession>> getTimeTrackingSessionsByTask(
    String taskId,
  ) async {
    return await _dbService.getTimeTrackingSessionsByTask(taskId);
  }

  Future<List<TimeTrackingSession>> getTimeTrackingSessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await _dbService.getTimeTrackingSessionsByDateRange(start, end);
  }

  Future<Duration> getTotalTimeSpentOnTask(String taskId) async {
    final sessions = await getTimeTrackingSessionsByTask(taskId);
    Duration total = Duration.zero;
    for (var session in sessions) {
      total += session.duration;
    }
    return total;
  }

  Future<Duration> getTotalTimeSpentInPeriod(
    DateTime start,
    DateTime end,
  ) async {
    return await _dbService.getTotalTimeSpent(start, end);
  }

  Future<Map<TaskCategory, Duration>> getTimeSpentByCategory(
    DateTime start,
    DateTime end,
  ) async {
    return await _dbService.getTotalTimeByCategory(start, end);
  }

  Future<AnalyticsData> getAnalyticsData(DateTime start, DateTime end) async {
    final timeByCategory = await getTimeSpentByCategory(start, end);
    final totalTimeSpent = await getTotalTimeSpentInPeriod(start, end);
    final totalTasksCompleted = await _dbService.getTotalTasksCompleted(
      start,
      end,
    );

    // Get top time-consuming tasks
    final allTasks = await TaskRepository().getAllTasks();
    final taskTimeMap = <String, Duration>{};

    for (var task in allTasks) {
      final timeSpent = await getTotalTimeSpentOnTask(task.id);
      if (timeSpent > Duration.zero) {
        taskTimeMap[task.id] = timeSpent;
      }
    }

    final sortedTasks = taskTimeMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topTimeConsumingTasks = sortedTasks.take(5).map((entry) {
      final task = allTasks.firstWhere((t) => t.id == entry.key);
      return TopTask(
        taskId: task.id,
        taskTitle: task.title,
        value: entry.value,
        category: task.category,
      );
    }).toList();

    // Get most postponed tasks
    final postponedTasks = await TaskRepository().getMostPostponedTasks(5);
    final mostPostponedTasks = postponedTasks.map((task) {
      return TopTask(
        taskId: task.id,
        taskTitle: task.title,
        value: Duration(
          days: task.postponeCount,
        ), // Using days as proxy for count
        category: task.category,
      );
    }).toList();

    // Calculate productivity score (simplified)
    final productivityScore = totalTasksCompleted > 0
        ? ((totalTasksCompleted / allTasks.length) * 100).clamp(0.0, 100.0)
        : 0.0;

    // Time distribution by hour (simplified)
    final timeByHour = <int, Duration>{};
    for (int hour = 0; hour < 24; hour++) {
      timeByHour[hour] = Duration.zero;
    }

    final sessions = await getTimeTrackingSessionsByDateRange(start, end);
    for (var session in sessions) {
      final hour = session.startTime.hour;
      timeByHour[hour] = timeByHour[hour]! + session.duration;
    }

    return AnalyticsData(
      periodStart: start,
      periodEnd: end,
      timeByCategory: timeByCategory,
      topTimeConsumingTasks: topTimeConsumingTasks,
      mostPostponedTasks: mostPostponedTasks,
      timeByHour: timeByHour,
      totalTasksCompleted: totalTasksCompleted,
      totalTimeSpent: totalTimeSpent,
      productivityScore: productivityScore,
    );
  }
}
