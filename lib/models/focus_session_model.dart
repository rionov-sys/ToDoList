enum FocusMode {
  focus(25, 'Fokus', 'Sesi kerja intensif'),
  shortBreak(5, 'Istirahat Singkat', 'Peregangan sejenak'),
  longBreak(15, 'Istirahat Panjang', 'Istirahat penuh & hidrasi');

  final int defaultMinutes;
  final String label;
  final String description;

  const FocusMode(this.defaultMinutes, this.label, this.description);
}

class FocusSessionModel {
  final String id;
  final String? taskId;
  final String taskTitle;
  final int durationMinutes;
  final FocusMode mode;
  final DateTime completedAt;

  const FocusSessionModel({
    required this.id,
    this.taskId,
    required this.taskTitle,
    required this.durationMinutes,
    required this.mode,
    required this.completedAt,
  });

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) {
    return FocusSessionModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String?,
      taskTitle: json['task_title'] as String? ?? 'General Focus',
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      mode: FocusMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => FocusMode.focus,
      ),
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'task_title': taskTitle,
      'duration_minutes': durationMinutes,
      'mode': mode.name,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}
