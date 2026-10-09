import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../models/calendar_summary_model.dart';
import '../services/task_service.dart';

enum CalendarViewMode { month, week, agenda }

class CalendarProvider extends ChangeNotifier {
  final TaskService _taskService;

  late DateTime _currentMonth;
  late DateTime _selectedDay;
  CalendarViewMode _viewMode = CalendarViewMode.month;
  Map<DateTime, CalendarSummaryModel> _summaryMap = {};
  bool _isLoading = false;

  CalendarProvider({required TaskService taskService}) : _taskService = taskService {
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  DateTime get currentMonth => _currentMonth;
  DateTime get selectedDay => _selectedDay;
  CalendarViewMode get viewMode => _viewMode;
  Map<DateTime, CalendarSummaryModel> get summaryMap => _summaryMap;
  bool get isLoading => _isLoading;

  Future<void> loadCalendarSummary() async {
    _isLoading = true;
    notifyListeners();

    try {
      _summaryMap = await _taskService.getCalendarSummary(_currentMonth);
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    loadCalendarSummary();
  }

  void prevMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    loadCalendarSummary();
  }

  void selectToday() {
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
    loadCalendarSummary();
  }

  void selectDay(DateTime day) {
    _selectedDay = DateTime(day.year, day.month, day.day);
    notifyListeners();
  }

  void setViewMode(CalendarViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  List<TaskModel> getAgendaTasksForSelectedDay(List<TaskModel> allTasks) {
    return allTasks.where((task) {
      final taskDate = DateTime(task.startTime.year, task.startTime.month, task.startTime.day);
      return taskDate.isAtSameMomentAs(_selectedDay);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
}
