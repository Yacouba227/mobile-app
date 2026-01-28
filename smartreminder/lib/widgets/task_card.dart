import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onComplete;
  final VoidCallback? onPostpone;
  final VoidCallback? onTap;

  const TaskCard({
    Key? key,
    required this.task,
    this.onEdit,
    this.onDelete,
    this.onComplete,
    this.onPostpone,
    this.onTap,
  }) : super(key: key);

  static const primaryBlue = Color(0xFF1976D2);
  static const secondaryBlue = Color(0xFF42A5F5);
  static const successGreen = Color(0xFF4CAF50);
  static const warningOrange = Color(0xFFFF9800);
  static const errorRed = Color(0xFFF44336);

  @override
  Widget build(BuildContext context) {
    final color = Color(task.category.colorValue);

    return Slidable(
      key: ValueKey(task.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onPostpone?.call(),
            backgroundColor: warningOrange,
            foregroundColor: Colors.white,
            icon: Icons.schedule,
            label: 'Reporter',
          ),
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: errorRed,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Supprimer',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: color, width: 4)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildPriorityIndicator(task.priority),
                    ],
                  ),
                  if (task.description != null &&
                      task.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      task.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.category.displayName,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStatusChip(task.status),
                      const Spacer(),
                      if (task.deadline != null)
                        _buildDeadlineInfo(task.deadline!),
                    ],
                  ),
                  if (task.estimatedDuration != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Durée estimée: ${_formatDuration(task.estimatedDuration!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (task.postponeCount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.repeat,
                          size: 16,
                          color: warningOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${task.postponeCount} report${task.postponeCount > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: warningOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(task.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      if (task.status == TaskStatus.completed)
                        Text(
                          'Terminée le ${DateFormat('dd/MM/yyyy').format(task.updatedAt)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: successGreen,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(TaskPriority priority) {
    Color color;
    IconData icon;

    switch (priority) {
      case TaskPriority.high:
        color = errorRed;
        icon = Icons.arrow_upward;
        break;
      case TaskPriority.medium:
        color = warningOrange;
        icon = Icons.remove;
        break;
      case TaskPriority.low:
        color = successGreen;
        icon = Icons.arrow_downward;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    String text;
    Color color;
    IconData? icon;

    switch (status) {
      case TaskStatus.pending:
        text = 'En attente';
        color = Colors.grey;
        icon = Icons.pending;
        break;
      case TaskStatus.inProgress:
        text = 'En cours';
        color = primaryBlue;
        icon = Icons.play_arrow;
        break;
      case TaskStatus.completed:
        text = 'Terminée';
        color = successGreen;
        icon = Icons.check_circle;
        break;
      case TaskStatus.postponed:
        text = 'Reportée';
        color = warningOrange;
        icon = Icons.schedule;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineInfo(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    final isOverdue = difference.isNegative;

    String text;
    Color color;

    if (isOverdue) {
      text = 'En retard';
      color = errorRed;
    } else if (difference.inHours < 24) {
      text = 'Bientôt';
      color = warningOrange;
    } else {
      text = DateFormat('dd/MM').format(deadline);
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isOverdue ? Icons.warning : Icons.event, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}min';
    } else {
      return '${duration.inMinutes}min';
    }
  }
}
