import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/localization.dart';

class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'ai_chat_channel',
    'AI Chat Notifications',
    description: 'Notifications for AI chat messages',
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse payload) {
        // Handle notification tap
      },
    );
  }

  Future<void> showNotification(String title, String body) async {
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ai_chat_channel',
          'AI Chat Notifications',
          channelDescription: 'Notifications for AI chat messages',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> showNewMessageNotification(
    String message, [
    String language = 'fr',
  ]) async {
    await showNotification(
      Localization.getText('newMessage', language),
      message,
    );
  }

  Future<void> showReminderNotification(
    String reminder, [
    String language = 'fr',
  ]) async {
    await showNotification(
      Localization.getText('reminder', language),
      reminder,
    );
  }
}
