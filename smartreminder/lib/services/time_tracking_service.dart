import 'dart:async';
import 'package:flutter/material.dart';
import '../models/time_tracking.dart';
import '../repositories/time_tracking_repository.dart';

class TimeTrackingService extends ChangeNotifier {
  final TimeTrackingRepository _timeTrackingRepository =
      TimeTrackingRepository();

  TimeTrackingSession? _currentSession;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  bool _isTracking = false;

  // Getters
  TimeTrackingSession? get currentSession => _currentSession;
  Duration get elapsedTime => _elapsedTime;
  bool get isTracking => _isTracking;
  String get formattedTime => _formatDuration(_elapsedTime);

  // Start tracking time for a task
  Future<void> startTracking(String taskId) async {
    if (_isTracking) {
      await stopTracking();
    }

    _currentSession = TimeTrackingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: taskId,
      startTime: DateTime.now(),
      duration: Duration.zero,
    );

    _isTracking = true;
    _elapsedTime = Duration.zero;

    // Start timer to update elapsed time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime = DateTime.now().difference(_currentSession!.startTime);
      notifyListeners();
    });

    notifyListeners();
  }

  // Stop tracking time
  Future<void> stopTracking() async {
    if (!_isTracking || _currentSession == null) return;

    _timer?.cancel();
    _timer = null;

    final endTime = DateTime.now();
    final duration = endTime.difference(_currentSession!.startTime);

    _currentSession = _currentSession!.copyWith(
      endTime: endTime,
      duration: duration,
      isCompleted: true,
    );

    // Save the session to database
    await _timeTrackingRepository.saveTimeTrackingSession(_currentSession!);

    _isTracking = false;
    _elapsedTime = Duration.zero;

    notifyListeners();

    // Reset current session after a delay to allow UI to show completion
    Future.delayed(const Duration(seconds: 2), () {
      _currentSession = null;
      notifyListeners();
    });
  }

  // Pause tracking (optional feature)
  void pauseTracking() {
    if (!_isTracking) return;

    _timer?.cancel();
    _timer = null;
    _isTracking = false;
    notifyListeners();
  }

  // Resume tracking (optional feature)
  void resumeTracking() {
    if (_isTracking || _currentSession == null) return;

    _currentSession = _currentSession!.copyWith(
      startTime: DateTime.now().subtract(_elapsedTime),
    );

    _isTracking = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime = DateTime.now().difference(_currentSession!.startTime);
      notifyListeners();
    });

    notifyListeners();
  }

  // Add interruption to current session
  Future<void> addInterruption(String? reason) async {
    if (_currentSession == null) return;

    final interruption = Interruption(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      duration: Duration.zero,
      reason: reason,
    );

    _currentSession = _currentSession!.copyWith(
      interruptions: [..._currentSession!.interruptions, interruption],
    );

    notifyListeners();
  }

  // Complete current interruption
  Future<void> completeInterruption() async {
    if (_currentSession == null || _currentSession!.interruptions.isEmpty)
      return;

    final interruptions = List<Interruption>.from(
      _currentSession!.interruptions,
    );
    final lastInterruption = interruptions.last;

    if (lastInterruption.endTime == null) {
      final completedInterruption = lastInterruption.copyWith(
        endTime: DateTime.now(),
        duration: DateTime.now().difference(lastInterruption.startTime),
      );

      interruptions[interruptions.length - 1] = completedInterruption;

      _currentSession = _currentSession!.copyWith(interruptions: interruptions);

      notifyListeners();
    }
  }

  // Get total time spent on a task
  Future<Duration> getTotalTimeForTask(String taskId) async {
    return await _timeTrackingRepository.getTotalTimeSpentOnTask(taskId);
  }

  // Get time tracking sessions for a task
  Future<List<TimeTrackingSession>> getSessionsForTask(String taskId) async {
    return await _timeTrackingRepository.getTimeTrackingSessionsByTask(taskId);
  }

  // Format duration to readable string
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Dispose resources
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
