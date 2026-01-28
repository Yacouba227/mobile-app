import 'package:equatable/equatable.dart';

enum AlarmType {
  taskReminder('Rappel de tâche'),
  dailyAlarm('Alarme quotidienne'),
  weeklyAlarm('Alarme hebdomadaire'),
  customAlarm('Alarme personnalisée');

  final String displayName;
  const AlarmType(this.displayName);
}

enum AlarmFrequency {
  once('Unique'),
  daily('Quotidien'),
  weekly('Hebdomadaire'),
  monthly('Mensuel'),
  weekdays('Jours ouvrables');

  final String displayName;
  const AlarmFrequency(this.displayName);
}

class Alarm extends Equatable {
  final String id;
  final String? taskId; // Peut être associée à une tâche
  final String title;
  final String? description;
  final DateTime scheduledTime;
  final AlarmType type;
  final AlarmFrequency frequency;
  final bool isActive;
  final bool isSnoozed;
  final int snoozeDuration; // en minutes
  final List<int> daysOfWeek; // 0 = dimanche, 1 = lundi, etc.
  final int volume; // 0-100
  final String sound;
  final int vibratePattern; // 0 = aucun, 1 = court, 2 = long
  final int advanceNotice; // en minutes avant l'heure programmée
  final DateTime createdAt;
  final DateTime updatedAt;

  const Alarm({
    required this.id,
    this.taskId,
    required this.title,
    this.description,
    required this.scheduledTime,
    required this.type,
    required this.frequency,
    this.isActive = true,
    this.isSnoozed = false,
    this.snoozeDuration = 5,
    this.daysOfWeek = const [],
    this.volume = 80,
    this.sound = 'default',
    this.vibratePattern = 1,
    this.advanceNotice = 5,
    required this.createdAt,
    required this.updatedAt,
  });

  Alarm copyWith({
    String? id,
    String? taskId,
    String? title,
    String? description,
    DateTime? scheduledTime,
    AlarmType? type,
    AlarmFrequency? frequency,
    bool? isActive,
    bool? isSnoozed,
    int? snoozeDuration,
    List<int>? daysOfWeek,
    int? volume,
    String? sound,
    int? vibratePattern,
    int? advanceNotice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Alarm(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      isSnoozed: isSnoozed ?? this.isSnoozed,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      volume: volume ?? this.volume,
      sound: sound ?? this.sound,
      vibratePattern: vibratePattern ?? this.vibratePattern,
      advanceNotice: advanceNotice ?? this.advanceNotice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'title': title,
      'description': description,
      'scheduled_time': scheduledTime.millisecondsSinceEpoch,
      'type': type.index,
      'frequency': frequency.index,
      'is_active': isActive ? 1 : 0,
      'is_snoozed': isSnoozed ? 1 : 0,
      'snooze_duration': snoozeDuration,
      'days_of_week': daysOfWeek.join(','),
      'volume': volume,
      'sound': sound,
      'vibrate_pattern': vibratePattern,
      'advance_notice': advanceNotice,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      taskId: map['task_id'],
      title: map['title'],
      description: map['description'],
      scheduledTime: DateTime.fromMillisecondsSinceEpoch(map['scheduled_time']),
      type: AlarmType.values[map['type']],
      frequency: AlarmFrequency.values[map['frequency']],
      isActive: map['is_active'] == 1,
      isSnoozed: map['is_snoozed'] == 1,
      snoozeDuration: map['snooze_duration'],
      daysOfWeek:
          (map['days_of_week'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .map((s) => int.parse(s))
              .toList() ??
          [],
      volume: map['volume'],
      sound: map['sound'],
      vibratePattern: map['vibrate_pattern'],
      advanceNotice: map['advance_notice'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    taskId,
    title,
    description,
    scheduledTime,
    type,
    frequency,
    isActive,
    isSnoozed,
    snoozeDuration,
    daysOfWeek,
    volume,
    sound,
    vibratePattern,
    advanceNotice,
    createdAt,
    updatedAt,
  ];
}
