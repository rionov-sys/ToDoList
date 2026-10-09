import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../models/timeline_log_model.dart';
import '../services/task_service.dart';

enum TaskFetchStatus { initial, loading, loaded, error }

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;

  List<TaskModel> _tasks = [];
  TaskFetchStatus _status = TaskFetchStatus.initial;
  String? _errorMessage;
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isSyncing = false;

  TaskProvider({required TaskService taskService}) : _taskService = taskService;

  List<TaskModel> get allTasks => _tasks;
  TaskFetchStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isSyncing => _isSyncing;

  // Filtered Task List
  List<TaskModel> get filteredTasks {
    return _tasks.where((task) {
      final matchesCategory = _selectedCategory == 'all' || task.categoryId == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  // Momentum & Bento Metrics
  int get totalTasksCount => _tasks.length;
  int get completedTasksCount => _tasks.where((t) => t.isCompleted).length;
  int get inProgressTasksCount => _tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get urgentTasksCount => _tasks.where((t) => t.priority == TaskPriority.urgent && !t.isCompleted).length;

  int get momentumPercentage {
    if (_tasks.isEmpty) return 0;
    return ((completedTasksCount / _tasks.length) * 100).round();
  }

  Future<void> loadTasks() async {
    _status = TaskFetchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks();
      _status = TaskFetchStatus.loaded;
    } catch (e) {
      _errorMessage = 'Gagal memuat tugas: ${e.toString()}';
      _status = TaskFetchStatus.error;
    }
    notifyListeners();
  }

  void setCategoryFilter(String categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> addTask(TaskModel task) async {
    try {
      final created = await _taskService.createTask(task);
      _tasks = [created, ..._tasks];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambahkan tugas: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    try {
      final updated = await _taskService.updateTask(task);
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        _tasks[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui tugas: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTaskProgress({
    required String taskId,
    required int progressPercentage,
    required TaskStatus status,
    String? note,
  }) async {
    try {
      final updated = await _taskService.updateTaskProgress(
        taskId: taskId,
        progressPercentage: progressPercentage,
        status: status,
        note: note,
      );
      final idx = _tasks.indexWhere((t) => t.id == taskId);
      if (idx != -1) {
        _tasks[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui progres: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTaskCompletion(String taskId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return false;

    final task = _tasks[idx];
    final newStatus = task.isCompleted ? TaskStatus.inProgress : TaskStatus.completed;
    final newProgress = task.isCompleted ? 50 : 100;

    return updateTaskProgress(
      taskId: taskId,
      progressPercentage: newProgress,
      status: newStatus,
      note: task.isCompleted ? 'Tugas dibuka kembali' : 'Tugas diselesaikan via checklist cepat',
    );
  }

  Future<bool> toggleSubtask(String taskId, String subtaskId) async {
    final taskIdx = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIdx == -1) return false;

    final task = _tasks[taskIdx];
    final updatedSubtasks = task.subtasks.map((s) {
      if (s.id == subtaskId) {
        return s.copyWith(isCompleted: !s.isCompleted);
      }
      return s;
    }).toList();

    // Auto-calculate progress based on subtasks if any
    int newProgress = task.progressPercentage;
    TaskStatus newStatus = task.status;
    if (updatedSubtasks.isNotEmpty) {
      final completedCount = updatedSubtasks.where((s) => s.isCompleted).length;
      newProgress = ((completedCount / updatedSubtasks.length) * 100).round();
      if (newProgress == 100) {
        newStatus = TaskStatus.completed;
      } else if (newProgress > 0 && newStatus == TaskStatus.todo) {
        newStatus = TaskStatus.inProgress;
      }
    }

    final updatedTask = task.copyWith(
      subtasks: updatedSubtasks,
      progressPercentage: newProgress,
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    return updateTask(updatedTask);
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus tugas: $e';
      notifyListeners();
      return false;
    }
  }

  Future<List<TimelineLogModel>> getTaskTimelineLogs(String taskId) async {
    return _taskService.getTimelineLogs(taskId);
  }

  Future<void> triggerManualSync() async {
    _isSyncing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200)); // Simulate sync telemetry
    await loadTasks();

    _isSyncing = false;
    notifyListeners();
  }
}
