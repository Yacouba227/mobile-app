import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_view_model.dart';
import '../widgets/task_card.dart';
import '../models/task.dart';
import '../services/theme_service.dart';
import '../services/alarm_service.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

const primaryBlue = Color(0xFF1976D2);
const secondaryBlue = Color(0xFF42A5F5);
const successGreen = Color(0xFF4CAF50);
const warningOrange = Color(0xFFFF9800);
const errorRed = Color(0xFFF44336);
const lightBackground = Color(0xFFF5F5F5);

class _TaskListScreenState extends State<TaskListScreen> {
  TaskStatus? _selectedStatus;
  TaskCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskViewModel>(context, listen: false).loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SmartReminder',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm),
            onPressed: () {
              Navigator.pushNamed(context, '/alarms');
            },
            tooltip: 'Mes alarmes',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<TaskViewModel>(context, listen: false).loadTasks();
            },
            tooltip: 'Actualiser',
          ),
          Consumer<ThemeService?>(
            builder: (context, themeService, child) {
              if (themeService == null) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => themeService.toggleTheme(),
                tooltip: themeService.isDarkMode ? 'Mode clair' : 'Mode sombre',
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadTasks(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filtres
              _buildFilterSection(viewModel),

              // Statistiques
              _buildStatisticsSection(viewModel),

              // Liste des tâches
              Expanded(
                child: viewModel.tasks.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => viewModel.loadTasks(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: viewModel.tasks.length,
                          itemBuilder: (context, index) {
                            final task = viewModel.tasks[index];
                            return TaskCard(
                              task: task,
                              onTap: () => _navigateToDetail(task),
                              onEdit: () => _navigateToAddEdit(task),
                              onDelete: () => _confirmDelete(task),
                              onComplete: () =>
                                  viewModel.markTaskAsCompleted(task.id),
                              onPostpone: () => viewModel.postponeTask(task.id),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<AlarmService>(
        builder: (context, alarmService, child) {
          final activeAlarms = alarmService.activeAlarms;
          final hasActiveAlarms = activeAlarms
              .any((alarm) => alarm.isActive && !alarm.isSnoozed);

          if (hasActiveAlarms) {
            return FloatingActionButton.extended(
              onPressed: () {
                alarmService.stopAlarmSound();
                // Désactiver toutes les alarmes actives
                for (var alarm in activeAlarms) {
                  if (alarm.isActive && !alarm.isSnoozed) {
                    alarmService.updateAlarm(alarm.copyWith(isActive: false));
                  }
                }
              },
              backgroundColor: errorRed,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.volume_off),
              label: const Text('Stop Alarmes'),
            );
          } else {
            return FloatingActionButton(
              onPressed: _navigateToAddEdit,
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            );
          }
        },
      ),
    );
  }

  Widget _buildFilterSection(TaskViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: lightBackground.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: primaryBlue.withOpacity(0.2))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtres',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Tous'),
                selected: _selectedStatus == null && _selectedCategory == null,
                onSelected: (_) {
                  setState(() {
                    _selectedStatus = null;
                    _selectedCategory = null;
                  });
                  viewModel.showAllTasks();
                },
              ),
              ...TaskStatus.values.map(
                (status) => FilterChip(
                  label: Text(status.displayName),
                  selected: _selectedStatus == status,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? status : null;
                      _selectedCategory = null;
                    });
                    if (selected) {
                      viewModel.filterByStatus(status);
                    } else {
                      viewModel.showAllTasks();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ...TaskCategory.values.map(
                (category) => FilterChip(
                  label: Text(category.displayName),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                      _selectedStatus = null;
                    });
                    if (selected) {
                      viewModel.filterByCategory(category);
                    } else {
                      viewModel.showAllTasks();
                    }
                  },
                  backgroundColor: Color(category.colorValue).withOpacity(0.1),
                  selectedColor: Color(category.colorValue).withOpacity(0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(TaskViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 218, 218, 218),
        border: Border(bottom: BorderSide(color: primaryBlue.withOpacity(0.1))),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', viewModel.totalTasks.toString(), primaryBlue),
          _buildStatItem(
            'Terminées',
            viewModel.completedTasks.toString(),
            successGreen,
          ),
          _buildStatItem(
            'En cours',
            viewModel.inProgressTasks.toString(),
            secondaryBlue,
          ),
          _buildStatItem(
            'Reportées',
            viewModel.postponedTasks.toString(),
            warningOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Aucune tâche trouvée',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateMessage(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddEdit,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une tâche'),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    if (_selectedStatus != null) {
      return 'Aucune tâche avec le statut "${_selectedStatus!.displayName}"';
    } else if (_selectedCategory != null) {
      return 'Aucune tâche dans la catégorie "${_selectedCategory!.displayName}"';
    } else {
      return 'Commencez par ajouter votre première tâche !';
    }
  }

  void _navigateToAddEdit([Task? task]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen(task: task)),
    );

    if (result is Task) {
      final viewModel = Provider.of<TaskViewModel>(context, listen: false);
      if (task == null) {
        // Adding new task
        await viewModel.addTask(result);
      } else {
        // Editing existing task
        await viewModel.updateTask(result);
      }
    }
  }

  void _navigateToDetail(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
    );
  }

  void _confirmDelete(Task task) {
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
                Provider.of<TaskViewModel>(
                  context,
                  listen: false,
                ).deleteTask(task.id);
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
