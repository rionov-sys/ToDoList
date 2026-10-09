import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../models/timeline_log_model.dart';

class LocalStorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --- Auth & User Persistence ---
  Future<void> saveUser(UserModel user) async {
    await init();
    await _prefs?.setString(AppConstants.keyUserData, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    await init();
    final data = _prefs?.getString(AppConstants.keyUserData);
    if (data == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await init();
    await _prefs?.setString(AppConstants.keyAccessToken, accessToken);
    await _prefs?.setString(AppConstants.keyRefreshToken, refreshToken);
  }

  Future<String?> getAccessToken() async {
    await init();
    return _prefs?.getString(AppConstants.keyAccessToken);
  }

  Future<void> clearAuth() async {
    await init();
    await _prefs?.remove(AppConstants.keyAccessToken);
    await _prefs?.remove(AppConstants.keyRefreshToken);
    await _prefs?.remove(AppConstants.keyUserData);
  }

  // --- Tasks Cache Persistence (Offline-First) ---
  Future<void> saveTasks(List<TaskModel> tasks) async {
    await init();
    final jsonList = tasks.map((t) => t.toJson()).toList();
    await _prefs?.setString(AppConstants.keyTasksCache, jsonEncode(jsonList));
  }

  Future<List<TaskModel>> getTasks() async {
    await init();
    final data = _prefs?.getString(AppConstants.keyTasksCache);
    if (data == null) return [];
    try {
      final decoded = jsonDecode(data) as List<dynamic>;
      return decoded.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // --- Timeline Logs Persistence ---
  Future<void> saveTimelineLogs(String taskId, List<TimelineLogModel> logs) async {
    await init();
    final key = 'chronos_timeline_logs_$taskId';
    final jsonList = logs.map((l) => l.toJson()).toList();
    await _prefs?.setString(key, jsonEncode(jsonList));
  }

  Future<List<TimelineLogModel>> getTimelineLogs(String taskId) async {
    await init();
    final key = 'chronos_timeline_logs_$taskId';
    final data = _prefs?.getString(key);
    if (data == null) return [];
    try {
      final decoded = jsonDecode(data) as List<dynamic>;
      return decoded.map((e) => TimelineLogModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // --- Offline Sync Queue ---
  Future<void> addToOfflineQueue(Map<String, dynamic> action) async {
    await init();
    final queue = await getOfflineQueue();
    queue.add(action);
    await _prefs?.setString(AppConstants.keyOfflineQueue, jsonEncode(queue));
  }

  Future<List<Map<String, dynamic>>> getOfflineQueue() async {
    await init();
    final data = _prefs?.getString(AppConstants.keyOfflineQueue);
    if (data == null) return [];
    try {
      final decoded = jsonDecode(data) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearOfflineQueue() async {
    await init();
    await _prefs?.remove(AppConstants.keyOfflineQueue);
  }
}
