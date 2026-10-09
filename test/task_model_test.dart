import 'package:flutter_test/flutter_test.dart';
import 'package:chronos_todolist/models/task_model.dart';
import 'package:chronos_todolist/models/timeline_log_model.dart';
import 'package:chronos_todolist/models/user_model.dart';

void main() {
  group('Chronos Data Models Tests', () {
    test('TaskModel serialization & calculation', () {
      final now = DateTime.now();
      final task = TaskModel(
        id: 'task_test_1',
        userId: 'usr_test_1',
        title: 'Unit Test Task',
        description: 'Test description',
        status: TaskStatus.IN_PROGRESS,
        priority: TaskPriority.URGENT,
        progressPercentage: 50,
        startTime: now,
        dueTime: now.add(const Duration(hours: 2)),
        subtasks: const [
          SubTaskModel(id: 'st_1', title: 'Subtask 1', isCompleted: true),
          SubTaskModel(id: 'st_2', title: 'Subtask 2', isCompleted: false),
        ],
        createdAt: now,
        updatedAt: now,
      );

      expect(task.isCompleted, false);
      expect(task.completedSubtasksCount, 1);
      expect(task.totalSubtasksCount, 2);

      final json = task.toJson();
      final fromJson = TaskModel.fromJson(json);

      expect(fromJson.id, task.id);
      expect(fromJson.title, task.title);
      expect(fromJson.status, TaskStatus.IN_PROGRESS);
      expect(fromJson.priority, TaskPriority.URGENT);
      expect(fromJson.subtasks.length, 2);
    });

    test('UserModel initials calculation', () {
      final user = UserModel(
        id: 'usr_1',
        email: 'alex.kusuma@chronos.io',
        name: 'Alex Kusuma',
        createdAt: DateTime.now(),
      );

      expect(user.initials, 'AK');
    });

    test('TimelineLogModel serialization', () {
      final now = DateTime.now();
      final log = TimelineLogModel(
        id: 'log_1',
        taskId: 'task_1',
        oldStatus: 'TODO',
        newStatus: 'IN_PROGRESS',
        progressDelta: 25,
        note: 'Memulai pengerjaan modul auth',
        recordedAt: now,
      );

      final json = log.toJson();
      final parsed = TimelineLogModel.fromJson(json);

      expect(parsed.progressDelta, 25);
      expect(parsed.newStatus, 'IN_PROGRESS');
      expect(parsed.note, 'Memulai pengerjaan modul auth');
    });
  });
}
