import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Set a default timezone as fallback
      tz.setLocalLocation(tz.getLocation('Europe/Paris'));
    } catch (e) {
      print('Timezone initialization error: $e');
      // Continue anyway, notifications might still work
    }

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iOSsettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // General initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSsettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    // Could navigate to specific task or app section
    print('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleTaskReminder(Task task) async {
    if (task.deadline == null) return;

    try {
      // Cancel any existing notifications for this task
      await cancelTaskReminder(task.id);

      final now = DateTime.now();
      final deadline = task.deadline!;

      // Don't schedule if deadline has already passed
      if (deadline.isBefore(now)) return;

      // Schedule multiple reminders at different intervals
      final reminders = _calculateReminderTimes(deadline, now, task.priority);

      for (int i = 0; i < reminders.length; i++) {
        final reminderTime = reminders[i];
        final notificationId = _generateNotificationId(task.id, i);

        final androidDetails = AndroidNotificationDetails(
          'task_reminders',
          'Rappels de tâches',
          channelDescription: 'Notifications pour les rappels de tâches',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          ongoing: false,
          autoCancel: true,
        );

        final iOSDetails = DarwinNotificationDetails(
          badgeNumber: 1,
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        final details = NotificationDetails(
          android: androidDetails,
          iOS: iOSDetails,
        );

        final title = _getReminderTitle(task, i, reminders.length);
        final body = _getReminderBody(task, reminderTime);

        await _notificationsPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          reminderTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: task.id,
        );
      }
    } catch (e) {
      print('Error scheduling notification: $e');
      // Don't throw error, let task creation continue
    }
  }

  List<tz.TZDateTime> _calculateReminderTimes(
    DateTime deadline,
    DateTime now,
    TaskPriority priority,
  ) {
    final tz.TZDateTime deadlineTZ = tz.TZDateTime.from(deadline, tz.local);
    final tz.TZDateTime nowTZ = tz.TZDateTime.from(now, tz.local);

    List<tz.TZDateTime> reminders = [];

    switch (priority) {
      case TaskPriority.high:
        // High priority: 1 day, 6 hours, 1 hour, 15 minutes before
        reminders.addAll([
          deadlineTZ.subtract(const Duration(days: 1)),
          deadlineTZ.subtract(const Duration(hours: 6)),
          deadlineTZ.subtract(const Duration(hours: 1)),
          deadlineTZ.subtract(const Duration(minutes: 15)),
        ]);
        break;
      case TaskPriority.medium:
        // Medium priority: 1 day, 3 hours, 30 minutes before
        reminders.addAll([
          deadlineTZ.subtract(const Duration(days: 1)),
          deadlineTZ.subtract(const Duration(hours: 3)),
          deadlineTZ.subtract(const Duration(minutes: 30)),
        ]);
        break;
      case TaskPriority.low:
        // Low priority: 1 day, 1 hour before
        reminders.addAll([
          deadlineTZ.subtract(const Duration(days: 1)),
          deadlineTZ.subtract(const Duration(hours: 1)),
        ]);
        break;
    }

    // Filter out reminders that are in the past
    return reminders.where((reminder) => reminder.isAfter(nowTZ)).toList();
  }

  String _getReminderTitle(Task task, int reminderIndex, int totalReminders) {
    if (reminderIndex == totalReminders - 1) {
      return '🚨 Deadline imminente !';
    } else if (reminderIndex == 0) {
      return '📅 Rappel : ${task.title}';
    } else {
      return '⏰ Rappel : ${task.title}';
    }
  }

  String _getReminderBody(Task task, tz.TZDateTime reminderTime) {
    final timeUntil = reminderTime.difference(tz.TZDateTime.now(tz.local));
    final hours = timeUntil.inHours;
    final minutes = timeUntil.inMinutes % 60;

    if (hours > 0) {
      return 'Il vous reste $hours h $minutes min pour terminer "${task.title}"';
    } else {
      return 'Il vous reste $minutes min pour terminer "${task.title}"';
    }
  }

  Future<void> cancelTaskReminder(String taskId) async {
    // Cancel all notifications for this task (max 10 reminders per task)
    for (int i = 0; i < 10; i++) {
      final notificationId = _generateNotificationId(taskId, i);
      await _notificationsPlugin.cancel(notificationId);
    }
  }

  Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancelAll();
  }

  int _generateNotificationId(String taskId, int reminderIndex) {
    // Generate unique notification ID based on task ID and reminder index
    final hash = taskId.hashCode;
    return (hash.abs() % 1000000) + reminderIndex;
  }

  Future<bool> areNotificationsEnabled() async {
    final details = await _notificationsPlugin
        .getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp ?? false;
  }

  Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }
}
