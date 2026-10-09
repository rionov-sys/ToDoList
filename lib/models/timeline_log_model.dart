class TimelineLogModel {
  final String id;
  final String taskId;
  final String? oldStatus;
  final String newStatus;
  final int progressDelta;
  final String? note;
  final DateTime recordedAt;

  const TimelineLogModel({
    required this.id,
    required this.taskId,
    this.oldStatus,
    required this.newStatus,
    required this.progressDelta,
    this.note,
    required this.recordedAt,
  });

  factory TimelineLogModel.fromJson(Map<String, dynamic> json) {
    return TimelineLogModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      oldStatus: json['old_status'] as String?,
      newStatus: json['new_status'] as String,
      progressDelta: (json['progress_delta'] as num).toInt(),
      note: json['note'] as String?,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'old_status': oldStatus,
      'new_status': newStatus,
      'progress_delta': progressDelta,
      'note': note,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }
}
