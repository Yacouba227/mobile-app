import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/alarm.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class AlarmService extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  Timer? _timer;
  List<Alarm> _alarms = [];

  List<Alarm> get alarms => _alarms;
  List<Alarm> get activeAlarms =>
      _alarms.where((alarm) => alarm.isActive).toList();

  AlarmService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadAlarms();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkForActiveAlarms();
    });
  }

  void _checkForActiveAlarms() {
    final now = DateTime.now();
    final activeAlarms = _alarms
        .where((alarm) => alarm.isActive && !alarm.isSnoozed)
        .toList();

    for (final alarm in activeAlarms) {
      final scheduledTimeWithNotice = alarm.scheduledTime.subtract(
        Duration(minutes: alarm.advanceNotice),
      );

      // Vérifier si l'alarme doit se déclencher
      if (_shouldTriggerAlarm(alarm, now)) {
        _triggerAlarm(alarm);
      }
    }
  }

  bool _shouldTriggerAlarm(Alarm alarm, DateTime now) {
    switch (alarm.frequency) {
      case AlarmFrequency.once:
        return now.difference(alarm.scheduledTime).inSeconds.abs() <
            5; // 5 secondes de tolérance
      case AlarmFrequency.daily:
        return now.hour == alarm.scheduledTime.hour &&
            now.minute == alarm.scheduledTime.minute &&
            now.second < 5; // Seconde 0-4
      case AlarmFrequency.weekly:
        return alarm.daysOfWeek.contains(now.weekday) &&
            now.hour == alarm.scheduledTime.hour &&
            now.minute == alarm.scheduledTime.minute &&
            now.second < 5;
      case AlarmFrequency.weekdays:
        if (now.weekday >= 1 && now.weekday <= 5) {
          // Lundi à vendredi
          return now.hour == alarm.scheduledTime.hour &&
              now.minute == alarm.scheduledTime.minute &&
              now.second < 5;
        }
        return false;
      case AlarmFrequency.monthly:
        // Pour simplifier, on vérifie seulement l'heure
        return now.day == alarm.scheduledTime.day &&
            now.hour == alarm.scheduledTime.hour &&
            now.minute == alarm.scheduledTime.minute &&
            now.second < 5;
    }
  }

  void _triggerAlarm(Alarm alarm) {
    // Afficher une notification ou alerte
    _showAlarmNotification(alarm);

    // Si c'est une alarme ponctuelle, la désactiver
    if (alarm.frequency == AlarmFrequency.once) {
      updateAlarm(alarm.copyWith(isActive: false));
    }
  }

  void _showAlarmNotification(Alarm alarm) {
    // Jouer un son d'alarme
    _playAlarmSound(alarm);

    // Afficher une notification système
    _showSystemNotification(alarm);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        // App est au premier plan - afficher une alerte
        _showInAppAlert(alarm);
      }
    });
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playAlarmSound(Alarm alarm) async {
    try {
      // Jouer le son d'alarme personnalisé
      await _audioPlayer.setSource(AssetSource('assets/audio/Infinite_excitement.mp3'));
      await _audioPlayer.setVolume(alarm.volume / 100.0); // Volume entre 0.0 et 1.0
      await _audioPlayer.resume();
      
      // Boucler le son si l'alarme est active
      _audioPlayer.onPlayerComplete.listen((event) {
        if (alarm.isActive && !alarm.isSnoozed) {
          _audioPlayer.resume(); // Rejouer le son
        }
      });
    } catch (e) {
      print('Erreur lors de la lecture du son d\'alarme: \$e');
      // Fallback : utiliser les notifications sonores du système
      _showSystemNotification(alarm);
    }
  }

  void _triggerVibration() {
    // Pour l'instant, on fait juste un print
    // Dans une vraie application, on utiliserait le plugin vibration
    print('Vibration déclenchée');
  }

  void _showSystemNotification(Alarm alarm) {
    // Créer une tâche temporaire pour utiliser le service de notification existant
    final tempTask = Task(
      id: alarm.id,
      title: alarm.title,
      description: alarm.description,
      category: TaskCategory.personal,
      priority: TaskPriority.medium,
      deadline: DateTime.now().add(const Duration(seconds: 1)),
      status: TaskStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final notificationService = NotificationService();
    notificationService.scheduleTaskReminder(tempTask);
  }

  void _showInAppAlert(Alarm alarm) {
    // Pour l'instant, on affiche un simple print
    // Dans une vraie application, on pourrait utiliser une alerte ou un overlay
    print('Alerte interne: ${alarm.title}');
  }

  Future<void> loadAlarms() async {
    // Pour l'instant, on simule le chargement
    // Dans une vraie application, on chargerait depuis la base de données
    _alarms = [
      Alarm(
        id: 'alarm_demo_1',
        title: 'Rappel de tâche',
        description: 'Ceci est une alarme de démonstration',
        scheduledTime: DateTime.now().add(
          const Duration(seconds: 30),
        ), // Alarme dans 30 secondes
        type: AlarmType.taskReminder,
        frequency: AlarmFrequency.once,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    notifyListeners();
  }

  Future<void> addAlarm(Alarm alarm) async {
    _alarms.add(alarm);
    notifyListeners();
    // Ici, on sauvegarderait dans la base de données
  }

  Future<void> updateAlarm(Alarm alarm) async {
    final index = _alarms.indexWhere((a) => a.id == alarm.id);
    if (index != -1) {
      // Si l'alarme était active et devient inactive, arrêter le son
      if (_alarms[index].isActive && !alarm.isActive) {
        await stopAlarmSound();
      }
      _alarms[index] = alarm;
      notifyListeners();
    }
  }

  Future<void> deleteAlarm(String alarmId) async {
    _alarms.removeWhere((alarm) => alarm.id == alarmId);
    notifyListeners();
  }

  Future<void> snoozeAlarm(String alarmId) async {
    final index = _alarms.indexWhere((a) => a.id == alarmId);
    if (index != -1) {
      final alarm = _alarms[index];
      _alarms[index] = alarm.copyWith(isSnoozed: true);
      notifyListeners();

      // Réinitialiser l'alarme après la durée de snooze
      Timer(Duration(minutes: alarm.snoozeDuration), () {
        final snoozedIndex = _alarms.indexWhere((a) => a.id == alarmId);
        if (snoozedIndex != -1) {
          _alarms[snoozedIndex] = _alarms[snoozedIndex].copyWith(
            isSnoozed: false,
          );
          notifyListeners();
        }
      });
    }
  }

  Future<void> activateAlarm(String alarmId) async {
    final index = _alarms.indexWhere((a) => a.id == alarmId);
    if (index != -1) {
      _alarms[index] = _alarms[index].copyWith(
        isSnoozed: false,
        isActive: true,
      );
      notifyListeners();
    }
  }

  Future<void> stopAlarmSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Erreur lors de l\'arrêt du son d\'alarme: \$e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
