import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/task_list_screen.dart';
import 'views/alarm_list_screen.dart';
import 'viewmodels/task_view_model.dart';
import 'services/notification_service.dart';
import 'services/time_tracking_service.dart';
import 'services/theme_service.dart';
import 'services/alarm_service.dart';
import 'utils/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskViewModel()),
        ChangeNotifierProvider(create: (context) => TimeTrackingService()),
        ChangeNotifierProvider(create: (context) => ThemeService()),
        ChangeNotifierProvider(create: (context) => AlarmService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'SmartReminder',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeService.themeMode,
            home: const TaskListScreen(),
            routes: {'/alarms': (context) => const AlarmListScreen()},
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
