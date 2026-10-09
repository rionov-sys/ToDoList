class CalendarSummaryModel {
  final DateTime date;
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;

  const CalendarSummaryModel({
    required this.date,
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
  });

  int get remainingTasks => totalTasks - completedTasks;
  double get completionRate =>
      totalTasks == 0 ? 0 : (completedTasks / totalTasks);

  factory CalendarSummaryModel.fromJson(String dateKey, Map<String, dynamic> json) {
    return CalendarSummaryModel(
      date: DateTime.parse(dateKey),
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,
      overdueTasks: (json['overdueTasks'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'overdueTasks': overdueTasks,
    };
  }
}
