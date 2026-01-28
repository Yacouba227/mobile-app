import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm.dart';
import '../services/alarm_service.dart';

class AlarmListScreen extends StatelessWidget {
  const AlarmListScreen({Key? key}) : super(key: key);

  static const primaryBlue = Color(0xFF1976D2);
  static const secondaryBlue = Color(0xFF42A5F5);
  static const successGreen = Color(0xFF4CAF50);
  static const warningOrange = Color(0xFFFF9800);
  static const errorRed = Color(0xFFF44336);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Alarmes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Consumer<AlarmService>(
        builder: (context, alarmService, child) {
          final alarms = alarmService.alarms;

          if (alarms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune alarme configurée',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ajoutez votre première alarme',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddAlarm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une alarme'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Actualiser les alarmes
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return _buildAlarmCard(context, alarm, alarmService);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddAlarm(context),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAlarmCard(
    BuildContext context,
    Alarm alarm,
    AlarmService alarmService,
  ) {
    Color statusColor = alarm.isActive ? successGreen : errorRed;
    IconData statusIcon = alarm.isActive ? Icons.alarm_on : Icons.alarm_off;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          alarm.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Heure: ${_formatTime(alarm.scheduledTime)}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              alarm.type.displayName,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (alarm.description != null && alarm.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      alarm.description!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                Text(
                  'Fréquence: ${alarm.frequency.displayName}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (alarm.isActive)
                      ElevatedButton.icon(
                        onPressed: () {
                          alarmService.snoozeAlarm(alarm.id);
                        },
                        icon: const Icon(Icons.snooze),
                        label: const Text('Snooze'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: warningOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (alarm.isActive) {
                          alarmService.updateAlarm(alarm.copyWith(isActive: false));
                        } else {
                          alarmService.updateAlarm(alarm.copyWith(isActive: true));
                        }
                      },
                      icon: Icon(
                        alarm.isActive ? Icons.alarm_off : Icons.alarm_on,
                      ),
                      label: Text(alarm.isActive ? 'Désactiver' : 'Activer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: alarm.isActive
                            ? errorRed
                            : successGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        alarmService.stopAlarmSound();
                      },
                      icon: const Icon(Icons.volume_off),
                      label: const Text('Stop Son'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: warningOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _editAlarm(context, alarm),
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _confirmDelete(context, alarm, alarmService),
                      icon: const Icon(Icons.delete),
                      label: const Text('Supprimer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: errorRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToAddAlarm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAlarmScreen()),
    );
  }

  void _editAlarm(BuildContext context, Alarm alarm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAlarmScreen(existingAlarm: alarm),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    Alarm alarm,
    AlarmService alarmService,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer l\'alarme "${alarm.title}" ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                alarmService.deleteAlarm(alarm.id);
                Navigator.pop(context);
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AddAlarmScreen extends StatefulWidget {
  final Alarm? existingAlarm;

  const AddAlarmScreen({Key? key, this.existingAlarm}) : super(key: key);

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  AlarmType _selectedType = AlarmType.taskReminder;
  AlarmFrequency _selectedFrequency = AlarmFrequency.once;
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isActive = true;
  int _advanceNotice = 5;

  @override
  void initState() {
    super.initState();
    if (widget.existingAlarm != null) {
      final alarm = widget.existingAlarm!;
      _titleController.text = alarm.title;
      _descriptionController.text = alarm.description ?? '';
      _selectedType = alarm.type;
      _selectedFrequency = alarm.frequency;
      _selectedTime = TimeOfDay(
        hour: alarm.scheduledTime.hour,
        minute: alarm.scheduledTime.minute,
      );
      _isActive = alarm.isActive;
      _advanceNotice = alarm.advanceNotice;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingAlarm != null
              ? 'Modifier l\'alarme'
              : 'Nouvelle alarme',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AlarmListScreen.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  hintText: 'Nom de l\'alarme',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le titre est obligatoire';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Détails de l\'alarme',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Type d'alarme
              const Text(
                'Type d\'alarme *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AlarmType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.displayName),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = type;
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Fréquence
              const Text(
                'Fréquence *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AlarmFrequency.values.map((freq) {
                  return ChoiceChip(
                    label: Text(freq.displayName),
                    selected: _selectedFrequency == freq,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFrequency = freq;
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Heure
              ListTile(
                tileColor: Colors.grey[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                title: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: _selectTime,
              ),

              const SizedBox(height: 16),

              // Avertissement anticipé
              const Text(
                'Avertissement anticipé (minutes)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Slider(
                value: _advanceNotice.toDouble(),
                min: 0,
                max: 60,
                divisions: 60,
                label: '${_advanceNotice.toInt()} min',
                onChanged: (value) {
                  setState(() {
                    _advanceNotice = value.round();
                  });
                },
              ),

              const SizedBox(height: 32),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAlarm,
                      child: Text(
                        widget.existingAlarm != null
                            ? 'Mettre à jour'
                            : 'Créer',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveAlarm() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final alarm = Alarm(
        id:
            widget.existingAlarm?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        scheduledTime: scheduledTime,
        type: _selectedType,
        frequency: _selectedFrequency,
        isActive: _isActive,
        advanceNotice: _advanceNotice,
        createdAt: widget.existingAlarm?.createdAt ?? now,
        updatedAt: now,
      );

      // Sauvegarder via le service
      final alarmService = Provider.of<AlarmService>(context, listen: false);
      if (widget.existingAlarm != null) {
        alarmService.updateAlarm(alarm);
      } else {
        alarmService.addAlarm(alarm);
      }

      Navigator.pop(context);
    }
  }
}
