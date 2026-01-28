import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Task> get tasks => _filteredTasks;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get totalTasks => _tasks.length;
  int get completedTasks =>
      _tasks.where((task) => task.status == TaskStatus.completed).length;
  int get pendingTasks =>
      _tasks.where((task) => task.status == TaskStatus.pending).length;
  int get inProgressTasks =>
      _tasks.where((task) => task.status == TaskStatus.inProgress).length;
  int get postponedTasks =>
      _tasks.where((task) => task.status == TaskStatus.postponed).length;

  double get completionRate {
    if (_tasks.isEmpty) return 0.0;
    return (completedTasks / _tasks.length) * 100;
  }

  // Load all tasks
  Future<void> loadTasks() async {
    _setLoading(true);
    try {
      _tasks = await _repository.getAllTasks();
      _filteredTasks = List.from(_tasks);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des tâches: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Filter tasks
  void filterTasks(TaskStatus? status, TaskCategory? category) {
    _filteredTasks = _tasks.where((task) {
      bool statusMatch = status == null || task.status == status;
      bool categoryMatch = category == null || task.category == category;
      return statusMatch && categoryMatch;
    }).toList();
    notifyListeners();
  }

  void filterByStatus(TaskStatus status) {
    filterTasks(status, null);
  }

  void filterByCategory(TaskCategory category) {
    filterTasks(null, category);
  }

  void showAllTasks() {
    _filteredTasks = List.from(_tasks);
    notifyListeners();
  }

  // Task operations
  Future<void> addTask(Task task) async {
    try {
      await _repository.createTask(task);
      await loadTasks(); // Reload to get updated list
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout de la tâche: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _repository.updateTask(task);
      await loadTasks(); // Reload to get updated list
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour de la tâche: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
      await loadTasks(); // Reload to get updated list
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression de la tâche: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  Future<void> markTaskAsCompleted(String taskId) async {
    try {
      await _repository.markTaskAsCompleted(taskId);
      await loadTasks(); // Reload to get updated list
    } catch (e) {
      _errorMessage = 'Erreur lors du marquage comme terminée: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  Future<void> markTaskAsInProgress(String taskId) async {
    try {
      await _repository.markTaskAsInProgress(taskId);
      await loadTasks(); // Reload to get updated list
    } catch (e) {
      _errorMessage = 'Erreur lors du marquage comme en cours: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  Future<void> postponeTask(String taskId) async {
    try {
      await _repository.postponeTask(taskId);
      await loadTasks(); // Reload to get updated list
    } catch (e) {
      _errorMessage = 'Erreur lors du report de la tâche: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  // Get task by ID
  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get statistics
  Map<TaskCategory, int> getTaskCountByCategory() {
    final counts = <TaskCategory, int>{};
    for (var category in TaskCategory.values) {
      counts[category] = _tasks
          .where((task) => task.category == category)
          .length;
    }
    return counts;
  }

  List<Task> getMostPostponedTasks(int limit) {
    final postponedTasks = _tasks
        .where((task) => task.postponeCount > 0)
        .toList();
    postponedTasks.sort((a, b) => b.postponeCount.compareTo(a.postponeCount));
    return postponedTasks.take(limit).toList();
  }

  List<Task> getOverdueTasks() {
    final now = DateTime.now();
    return _tasks.where((task) {
      return task.deadline != null &&
          task.deadline!.isBefore(now) &&
          task.status != TaskStatus.completed;
    }).toList();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
