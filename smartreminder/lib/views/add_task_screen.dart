import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  const AddTaskScreen({Key? key, this.task}) : super(key: key);

  static const primaryBlue = Color(0xFF1976D2);
  static const secondaryBlue = Color(0xFF42A5F5);
  static const successGreen = Color(0xFF4CAF50);
  static const warningOrange = Color(0xFFFF9800);
  static const errorRed = Color(0xFFF44336);
  static const lightBackground = Color(0xFFF5F5F5);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;

  TaskCategory _selectedCategory = TaskCategory.personal;
  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskStatus _selectedStatus = TaskStatus.pending;
  DateTime? _selectedDeadline;
  Duration? _estimatedDuration;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.task != null;

    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _durationController = TextEditingController();

    if (widget.task != null) {
      _selectedCategory = widget.task!.category;
      _selectedPriority = widget.task!.priority;
      _selectedStatus = widget.task!.status;
      _selectedDeadline = widget.task!.deadline;
      _estimatedDuration = widget.task!.estimatedDuration;

      if (_estimatedDuration != null) {
        _durationController.text = _formatDuration(_estimatedDuration!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Modifier la tâche' : 'Nouvelle tâche',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
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
              _buildTextField(
                controller: _titleController,
                label: 'Titre *',
                hint: 'Entrez le titre de la tâche',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le titre est obligatoire';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Description détaillée de la tâche',
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Catégorie
              _buildCategorySelector(),

              const SizedBox(height: 16),

              // Priorité
              _buildPrioritySelector(),

              const SizedBox(height: 16),

              // Date limite
              _buildDeadlineSelector(),

              const SizedBox(height: 16),

              // Durée estimée
              _buildDurationInput(),

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
                      onPressed: _saveTask,
                      child: Text(_isEditing ? 'Mettre à jour' : 'Créer'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: true,
      ),
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catégorie *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: TaskCategory.values.map((category) {
            return ChoiceChip(
              label: Text(category.displayName),
              selected: _selectedCategory == category,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
              backgroundColor: Color(category.colorValue).withOpacity(0.1),
              selectedColor: Color(category.colorValue).withOpacity(0.3),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priorité *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: TaskPriority.values.map((priority) {
            return ChoiceChip(
              label: Text(priority.displayName),
              selected: _selectedPriority == priority,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedPriority = priority;
                  });
                }
              },
              selectedColor: _getPriorityColor(priority),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDeadlineSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Date limite',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (_selectedDeadline != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDeadline = null;
                  });
                },
                child: const Text('Supprimer'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ListTile(
          tileColor: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          title: Text(
            _selectedDeadline == null
                ? 'Sélectionner une date'
                : 'Le ${_formatDate(_selectedDeadline!)}',
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: _selectDeadline,
        ),
      ],
    );
  }

  Widget _buildDurationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durée estimée',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _durationController,
          decoration: InputDecoration(
            hintText: 'Ex: 2h 30min ou 90min',
            border: const OutlineInputBorder(),
            filled: true,
          ),
          onChanged: (value) {
            _parseDuration(value);
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'Format accepté: 2h 30min, 90min, 2.5h',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _selectDeadline() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          _selectedDeadline ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDeadline ?? DateTime.now().add(const Duration(hours: 1)),
        ),
      );

      if (pickedTime != null) {
        final DateTime deadline = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _selectedDeadline = deadline;
        });
      }
    }
  }

  void _parseDuration(String input) {
    if (input.isEmpty) {
      setState(() {
        _estimatedDuration = null;
      });
      return;
    }

    try {
      // Format: 2h 30min
      if (input.contains('h') && input.contains('min')) {
        final parts = input.split('h');
        final hours = int.parse(parts[0].trim());
        final minutes = int.parse(parts[1].replaceAll('min', '').trim());
        setState(() {
          _estimatedDuration = Duration(hours: hours, minutes: minutes);
        });
        return;
      }

      // Format: 90min
      if (input.contains('min')) {
        final minutes = int.parse(input.replaceAll('min', '').trim());
        setState(() {
          _estimatedDuration = Duration(minutes: minutes);
        });
        return;
      }

      // Format: 2.5h
      if (input.contains('h')) {
        final hours = double.parse(input.replaceAll('h', '').trim());
        setState(() {
          _estimatedDuration = Duration(minutes: (hours * 60).round());
        });
        return;
      }
    } catch (e) {
      // Invalid format, ignore
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}min';
    } else {
      return '${duration.inMinutes}min';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour.toString().padLeft(2, '0')}h${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AddTaskScreen.successGreen.withOpacity(0.3);
      case TaskPriority.medium:
        return AddTaskScreen.warningOrange.withOpacity(0.3);
      case TaskPriority.high:
        return AddTaskScreen.errorRed.withOpacity(0.3);
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final task = Task(
        id: widget.task?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        deadline: _selectedDeadline,
        estimatedDuration: _estimatedDuration,
        status: _selectedStatus,
        createdAt: widget.task?.createdAt ?? now,
        updatedAt: now,
        completionCount: widget.task?.completionCount ?? 0,
        postponeCount: widget.task?.postponeCount ?? 0,
        postponementHistory: widget.task?.postponementHistory ?? [],
      );

      Navigator.pop(context, task);
    }
  }
}
