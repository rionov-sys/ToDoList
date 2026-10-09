import '../core/network/api_client.dart';
import '../core/errors/failures.dart';
import '../models/task_model.dart';
import '../models/timeline_log_model.dart';
import '../models/calendar_summary_model.dart';
import 'local_storage_service.dart';

class TaskService {
  final ApiClient _apiClient;
  final LocalStorageService _localStorage;

  TaskService({
    required ApiClient apiClient,
    required LocalStorageService localStorage,
  })  : _apiClient = apiClient,
        _localStorage = localStorage;

  // --- GET TASKS (Offline-First) ---
  Future<List<TaskModel>> getTasks({TaskStatus? status, String? categoryId}) async {
    // 1. Try local cache first for instant zero-latency UI
    final cached = await _localStorage.getTasks();
    if (cached.isNotEmpty) {
      _fetchRemoteTasksInBackground(); // Trigger background sync
      return _filterTasks(cached, status, categoryId);
    }

    // 2. If local cache empty, try fetching from server
    try {
      final response = await _apiClient.dio.get('/tasks');
      final data = response.data['data'] as List<dynamic>;
      final tasks = data.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
      await _localStorage.saveTasks(tasks);
      return _filterTasks(tasks, status, categoryId);
    } catch (_) {
      // If offline & cache empty, initialize sample demo tasks
      final demoTasks = _generateInitialSampleTasks();
      await _localStorage.saveTasks(demoTasks);
      return _filterTasks(demoTasks, status, categoryId);
    }
  }

  // --- CREATE TASK ---
  Future<TaskModel> createTask(TaskModel task) async {
    // 1. Save immediately to local cache
    final currentTasks = await _localStorage.getTasks();
    final updatedTasks = [task, ...currentTasks];
    await _localStorage.saveTasks(updatedTasks);

    // Initial timeline log
    final initialLog = TimelineLogModel(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      taskId: task.id,
      oldStatus: null,
      newStatus: task.status.name,
      progressDelta: task.progressPercentage,
      note: 'Tugas berhasil dibuat di sistem',
      recordedAt: DateTime.now(),
    );
    await addTimelineLog(initialLog);

    // 2. Attempt remote sync
    try {
      final response = await _apiClient.dio.post(
        '/tasks',
        data: task.toJson(),
      );
      final savedRemote = TaskModel.fromJson(response.data['data'] as Map<String, dynamic>);
      return savedRemote;
    } catch (_) {
      // Queue for background sync
      await _localStorage.addToOfflineQueue({'action': 'CREATE', 'task': task.toJson()});
      return task.copyWith(isPendingSync: true);
    }
  }

  // --- UPDATE TASK ---
  Future<TaskModel> updateTask(TaskModel task) async {
    final currentTasks = await _localStorage.getTasks();
    final index = currentTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      currentTasks[index] = task;
      await _localStorage.saveTasks(currentTasks);
    }

    try {
      final response = await _apiClient.dio.patch(
        '/tasks/${task.id}',
        data: task.toJson(),
      );
      return TaskModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (_) {
      await _localStorage.addToOfflineQueue({'action': 'UPDATE', 'task': task.toJson()});
      return task.copyWith(isPendingSync: true);
    }
  }

  // --- UPDATE PROGRESS & TIMELINE LOG ---
  Future<TaskModel> updateTaskProgress({
    required String taskId,
    required int progressPercentage,
    required TaskStatus status,
    String? note,
  }) async {
    final currentTasks = await _localStorage.getTasks();
    final index = currentTasks.indexWhere((t) => t.id == taskId);
    if (index == -1) {
      throw const CacheFailure('Task tidak ditemukan.');
    }

    final oldTask = currentTasks[index];
    final progressDelta = progressPercentage - oldTask.progressPercentage;

    final updatedTask = oldTask.copyWith(
      progressPercentage: progressPercentage,
      status: status,
      actualCompletedAt: status == TaskStatus.completed ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );

    currentTasks[index] = updatedTask;
    await _localStorage.saveTasks(currentTasks);

    // Record timeline log
    final log = TimelineLogModel(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      taskId: taskId,
      oldStatus: oldTask.status.name,
      newStatus: status.name,
      progressDelta: progressDelta,
      note: note ?? (progressPercentage == 100 ? 'Tugas diselesaikan 100%' : 'Update progres menjadi $progressPercentage%'),
      recordedAt: DateTime.now(),
    );
    await addTimelineLog(log);

    try {
      await _apiClient.dio.patch(
        '/tasks/$taskId/progress',
        data: {
          'progressPercentage': progressPercentage,
          'status': status.name,
          'note': note,
        },
      );
    } catch (_) {
      await _localStorage.addToOfflineQueue({
        'action': 'PROGRESS',
        'taskId': taskId,
        'progress': progressPercentage,
        'status': status.name,
        'note': note,
      });
    }

    return updatedTask;
  }

  // --- DELETE TASK ---
  Future<void> deleteTask(String taskId) async {
    final currentTasks = await _localStorage.getTasks();
    currentTasks.removeWhere((t) => t.id == taskId);
    await _localStorage.saveTasks(currentTasks);

    try {
      await _apiClient.dio.delete('/tasks/$taskId');
    } catch (_) {
      await _localStorage.addToOfflineQueue({'action': 'DELETE', 'taskId': taskId});
    }
  }

  // --- TIMELINE LOGS ---
  Future<List<TimelineLogModel>> getTimelineLogs(String taskId) async {
    final cached = await _localStorage.getTimelineLogs(taskId);
    if (cached.isNotEmpty) return cached;

    // Generate initial sample logs for preview
    final sampleLogs = [
      TimelineLogModel(
        id: 'log_1',
        taskId: taskId,
        oldStatus: 'TODO',
        newStatus: 'IN_PROGRESS',
        progressDelta: 25,
        note: 'Memulai riset dan setup arsitektur dasar',
        recordedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      TimelineLogModel(
        id: 'log_2',
        taskId: taskId,
        oldStatus: 'IN_PROGRESS',
        newStatus: 'IN_PROGRESS',
        progressDelta: 50,
        note: 'Selesai integrasi model data & UI layout',
        recordedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
    await _localStorage.saveTimelineLogs(taskId, sampleLogs);
    return sampleLogs;
  }

  Future<void> addTimelineLog(TimelineLogModel log) async {
    final currentLogs = await _localStorage.getTimelineLogs(log.taskId);
    final updated = [log, ...currentLogs];
    await _localStorage.saveTimelineLogs(log.taskId, updated);
  }

  // --- CALENDAR SUMMARY ---
  Future<Map<DateTime, CalendarSummaryModel>> getCalendarSummary(DateTime month) async {
    final tasks = await _localStorage.getTasks();
    final Map<DateTime, CalendarSummaryModel> summaryMap = {};

    for (final task in tasks) {
      final taskDate = DateTime(task.startTime.year, task.startTime.month, task.startTime.day);
      if (taskDate.month == month.month && taskDate.year == month.year) {
        final existing = summaryMap[taskDate];
        final total = (existing?.totalTasks ?? 0) + 1;
        final completed = (existing?.completedTasks ?? 0) + (task.isCompleted ? 1 : 0);
        final overdue = (existing?.overdueTasks ?? 0) + (task.isOverdue ? 1 : 0);

        summaryMap[taskDate] = CalendarSummaryModel(
          date: taskDate,
          totalTasks: total,
          completedTasks: completed,
          overdueTasks: overdue,
        );
      }
    }

    return summaryMap;
  }

  // --- PRIVATE HELPERS ---
  List<TaskModel> _filterTasks(List<TaskModel> tasks, TaskStatus? status, String? categoryId) {
    return tasks.where((t) {
      if (status != null && t.status != status) return false;
      if (categoryId != null && categoryId != 'all' && t.categoryId != categoryId) return false;
      return true;
    }).toList();
  }

  Future<void> _fetchRemoteTasksInBackground() async {
    try {
      final response = await _apiClient.dio.get('/tasks');
      final data = response.data['data'] as List<dynamic>;
      final tasks = data.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
      await _localStorage.saveTasks(tasks);
    } catch (_) {
      // Silent background sync error
    }
  }

  List<TaskModel> _generateInitialSampleTasks() {
    final now = DateTime.now();
    return [
      TaskModel(
        id: 'task_1',
        userId: 'usr_demo_1',
        categoryId: 'cat_work',
        categoryName: 'Work',
        categoryColorHex: '#4F46E5',
        title: 'Implementasi BLoC State & Offline Cache',
        description: 'Integrasi flutter_bloc dengan local cache Isar untuk zero-latency offline experience.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.urgent,
        progressPercentage: 75,
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        dueTime: DateTime(now.year, now.month, now.day, 11, 30),
        subtasks: const [
          SubTaskModel(id: 'sub_1', title: 'Setup BLoC Observer & State Machine', isCompleted: true),
          SubTaskModel(id: 'sub_2', title: 'Implementasi Local Cache Repository', isCompleted: true),
          SubTaskModel(id: 'sub_3', title: 'Testing Offline Sync Queue Handler', isCompleted: false),
        ],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      TaskModel(
        id: 'task_2',
        userId: 'usr_demo_1',
        categoryId: 'cat_work',
        categoryName: 'Work',
        categoryColorHex: '#4F46E5',
        title: 'Desain UI Mobile & Wireframe Chronos',
        description: 'Menyusun komponen Material 3, typography, dan palet warna Indigo Slate.',
        status: TaskStatus.completed,
        priority: TaskPriority.high,
        progressPercentage: 100,
        startTime: DateTime(now.year, now.month, now.day, 8, 0),
        dueTime: DateTime(now.year, now.month, now.day, 9, 0),
        actualCompletedAt: DateTime(now.year, now.month, now.day, 8, 55),
        subtasks: const [
          SubTaskModel(id: 'sub_4', title: 'Wireframe Layout 390px', isCompleted: true),
          SubTaskModel(id: 'sub_5', title: 'Color Tokens & Typography Tokens', isCompleted: true),
        ],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      TaskModel(
        id: 'task_3',
        userId: 'usr_demo_1',
        categoryId: 'cat_work',
        categoryName: 'Work',
        categoryColorHex: '#4F46E5',
        title: 'Review PR Backend NestJS Auth & Session',
        description: 'Verifikasi JWT token rotation dan endpoint refresh session dengan Redis.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        progressPercentage: 50,
        startTime: DateTime(now.year, now.month, now.day, 13, 0),
        dueTime: DateTime(now.year, now.month, now.day, 14, 30),
        subtasks: const [
          SubTaskModel(id: 'sub_6', title: 'Check Argon2 password hashing', isCompleted: true),
          SubTaskModel(id: 'sub_7', title: 'Validasi token blacklisting Redis', isCompleted: false),
        ],
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      TaskModel(
        id: 'task_4',
        userId: 'usr_demo_1',
        categoryId: 'cat_study',
        categoryName: 'Study',
        categoryColorHex: '#4648D4',
        title: 'Membaca Dokumentasi Isar Database v3',
        description: 'Studi mendalam performa query NoSQL cross-platform di Flutter mobile.',
        status: TaskStatus.todo,
        priority: TaskPriority.low,
        progressPercentage: 0,
        startTime: DateTime(now.year, now.month, now.day, 15, 0),
        dueTime: DateTime(now.year, now.month, now.day, 16, 30),
        subtasks: const [
          SubTaskModel(id: 'sub_8', title: 'Bab Indexing & Compound Queries', isCompleted: false),
        ],
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      TaskModel(
        id: 'task_5',
        userId: 'usr_demo_1',
        categoryId: 'cat_personal',
        categoryName: 'Personal',
        categoryColorHex: '#10B981',
        title: 'Perencanaan Roadmap Q3 2025',
        description: 'Susun target sprint timeline dan alokasi resource proyek mobile.',
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        progressPercentage: 20,
        startTime: DateTime(now.year, now.month, now.day + 1, 10, 0),
        dueTime: DateTime(now.year, now.month, now.day + 1, 12, 0),
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
