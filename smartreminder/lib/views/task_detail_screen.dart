import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../viewmodels/task_view_model.dart';
import '../widgets/time_tracking_widget.dart';
import 'add_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  static const primaryGreen = Color(0xFF1B5E20);
  static const secondaryGreen = Color(0xFF4CAF50);
  static const lightGreen = Color(0xFFC8E6C9);

  @override
  Widget build(BuildContext context) {
    final color = Color(task.category.colorValue);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Détails de la tâche',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editTask(context),
            tooltip: 'Modifier',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec couleur de catégorie
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: color.withOpacity(0.1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      _buildPriorityBadge(task.priority, color),
                    ],
                  ),
                  if (task.description != null &&
                      task.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      task.description!,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildStatusRow(task, color),
                ],
              ),
            ),

            // Informations détaillées
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection('Informations générales', [
                    _buildInfoRow(
                      Icons.category,
                      'Catégorie',
                      task.category.displayName,
                      color,
                    ),
                    _buildInfoRow(
                      Icons.flag,
                      'Priorité',
                      task.priority.displayName,
                      _getPriorityColor(task.priority),
                    ),
                    if (task.deadline != null)
                      _buildInfoRow(
                        Icons.event,
                        'Date limite',
                        _formatDeadline(task.deadline!),
                        _getDeadlineColor(task.deadline!),
                      ),
                    if (task.estimatedDuration != null)
                      _buildInfoRow(
                        Icons.access_time,
                        'Durée estimée',
                        _formatDuration(task.estimatedDuration!),
                        Colors.blue,
                      ),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Créée le',
                      DateFormat('dd/MM/yyyy à HH:mm').format(task.createdAt),
                      Colors.grey,
                    ),
                    _buildInfoRow(
                      Icons.update,
                      'Dernière modification',
                      DateFormat('dd/MM/yyyy à HH:mm').format(task.updatedAt),
                      Colors.grey,
                    ),
                  ]),

                  const SizedBox(height: 32),

                  _buildStatsSection(context),

                  const SizedBox(height: 32),

                  _buildTimeTrackingSection(context),

                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(TaskPriority priority, Color baseColor) {
    IconData icon;
    String text;

    switch (priority) {
      case TaskPriority.high:
        icon = Icons.arrow_upward;
        text = 'Haute';
        break;
      case TaskPriority.medium:
        icon = Icons.remove;
        text = 'Moyenne';
        break;
      case TaskPriority.low:
        icon = Icons.arrow_downward;
        text = 'Basse';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(Task task, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(task.status), size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            task.status.displayName,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, viewModel, child) {
        return _buildInfoSection('Statistiques', [
          _buildStatRow(
            Icons.check_circle,
            'Nombre de complétions',
            task.completionCount.toString(),
            Colors.green,
          ),
          _buildStatRow(
            Icons.schedule,
            'Nombre de reports',
            task.postponeCount.toString(),
            Colors.orange,
          ),
          if (task.postponementHistory.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildHistorySection(),
          ],
        ]);
      },
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historique des reports',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: task.postponementHistory.asMap().entries.map((entry) {
              final index = entry.key;
              final date = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == task.postponementHistory.length - 1 ? 0 : 8,
                ),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}.',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        DateFormat('dd/MM/yyyy à HH:mm').format(date),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (task.status != TaskStatus.completed)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        viewModel.markTaskAsCompleted(task.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Marquer comme terminée'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (task.status != TaskStatus.completed &&
                    task.status != TaskStatus.postponed) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        viewModel.postponeTask(task.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.schedule),
                      label: const Text('Reporter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _confirmDelete(context, viewModel);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Supprimer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _editTask(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen(task: task)),
    );

    if (result != null && context.mounted) {
      Provider.of<TaskViewModel>(context, listen: false).updateTask(result);
      Navigator.pop(context, true);
    }
  }

  void _confirmDelete(BuildContext context, TaskViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer "${task.title}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                viewModel.deleteTask(task.id);
                Navigator.pop(context, true);
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

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.pending;
      case TaskStatus.inProgress:
        return Icons.play_arrow;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.postponed:
        return Icons.schedule;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  Color _getDeadlineColor(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return Colors.red;
    } else if (difference.inHours < 24) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'En retard depuis ${DateFormat('dd/MM/yyyy à HH:mm').format(deadline)}';
    } else if (difference.inHours < 24) {
      return 'Dans ${difference.inHours}h ${difference.inMinutes % 60}min';
    } else {
      return DateFormat('dd/MM/yyyy à HH:mm').format(deadline);
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}min';
    } else {
      return '${duration.inMinutes}min';
    }
  }

  Widget _buildTimeTrackingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suivi du temps',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TimeTrackingWidget(
          taskId: task.id,
          onTrackingStarted: () {
            // Optional: Show snackbar or update UI
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Suivi du temps démarré'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          onTrackingStopped: () {
            // Optional: Show snackbar or update UI
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Suivi du temps arrêté'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
