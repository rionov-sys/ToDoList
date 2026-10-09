import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

class TimelineProvider extends ChangeNotifier {
  late DateTime _selectedDate;
  String _activeTimeFilter = 'Semua';

  TimelineProvider() {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  DateTime get selectedDate => _selectedDate;
  String get activeTimeFilter => _activeTimeFilter;

  List<DateTime> get currentWeekDays {
    // Generate 7 days around current selected date
    final monday = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  void setTimeFilter(String filter) {
    _activeTimeFilter = filter;
    notifyListeners();
  }

  List<TaskModel> filterTasksForTimeline(List<TaskModel> allTasks) {
    return allTasks.where((task) {
      final taskDate = DateTime(task.startTime.year, task.startTime.month, task.startTime.day);
      final isSameDay = taskDate.isAtSameMomentAs(_selectedDate);
      if (!isSameDay) return false;

      if (_activeTimeFilter == 'Semua') return true;

      final hour = task.startTime.hour;
      if (_activeTimeFilter == 'Pagi') return hour >= 5 && hour < 12;
      if (_activeTimeFilter == 'Siang') return hour >= 12 && hour < 15;
      if (_activeTimeFilter == 'Sore') return hour >= 15 && hour < 18;
      if (_activeTimeFilter == 'Malam') return hour >= 18 || hour < 5;

      return true;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
}
