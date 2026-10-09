import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/focus_session_model.dart';
import '../models/task_model.dart';

enum TimerState { idle, running, paused, completed }

class FocusTimerProvider extends ChangeNotifier {
  FocusMode _currentMode = FocusMode.focus;
  TimerState _timerState = TimerState.idle;
  int _remainingSeconds = 25 * 60;
  int _totalSeconds = 25 * 60;
  Timer? _timer;

  TaskModel? _boundTask;
  int _completedSessionsToday = 3;
  int _totalFocusMinutesToday = 75;
  final int _sessionGoal = 4;

  FocusMode get currentMode => _currentMode;
  TimerState get timerState => _timerState;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  TaskModel? get boundTask => _boundTask;
  int get completedSessionsToday => _completedSessionsToday;
  int get totalFocusMinutesToday => _totalFocusMinutesToday;
  int get sessionGoal => _sessionGoal;

  double get progressRatio =>
      _totalSeconds == 0 ? 0.0 : 1.0 - (_remainingSeconds / _totalSeconds);

  String get formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void setMode(FocusMode mode) {
    _timer?.cancel();
    _currentMode = mode;
    _totalSeconds = mode.defaultMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _timerState = TimerState.idle;
    notifyListeners();
  }

  void bindTask(TaskModel? task) {
    _boundTask = task;
    notifyListeners();
  }

  void startTimer() {
    if (_timerState == TimerState.running) return;
    _timerState = TimerState.running;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _completeSession();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _timerState = TimerState.paused;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _remainingSeconds = _totalSeconds;
    _timerState = TimerState.idle;
    notifyListeners();
  }

  void _completeSession() {
    _timer?.cancel();
    _timerState = TimerState.completed;
    if (_currentMode == FocusMode.focus) {
      _completedSessionsToday++;
      _totalFocusMinutesToday += _currentMode.defaultMinutes;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
