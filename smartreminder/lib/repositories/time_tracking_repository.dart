import '../models/time_tracking.dart';
import '../services/database_service.dart';

class TimeTrackingRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<String> saveTimeTrackingSession(TimeTrackingSession session) async {
    return await _dbService.insertTimeTrackingSession(session);
  }

  Future<List<TimeTrackingSession>> getTimeTrackingSessionsByTask(
    String taskId,
  ) async {
    return await _dbService.getTimeTrackingSessionsByTask(taskId);
  }

  Future<Duration> getTotalTimeSpentOnTask(String taskId) async {
    final sessions = await getTimeTrackingSessionsByTask(taskId);
    Duration total = Duration.zero;
    for (var session in sessions) {
      total += session.duration;
    }
    return total;
  }

  Future<List<TimeTrackingSession>> getTimeTrackingSessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await _dbService.getTimeTrackingSessionsByDateRange(start, end);
  }
}
