import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompleted;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.urgent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Hapus Tugas?'),
                content: Text('Apakah Anda yakin ingin menghapus "${task.title}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Batal'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.urgent),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDone ? AppColors.completed.withOpacity(0.3) : AppColors.outlineHairline,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 3px Priority Strip along left inside edge
                  Container(
                    width: 4,
                    color: task.priority.color,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Category, Priority, and Status
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: task.categoryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      task.categoryName,
                                      style: AppTypography.labelSm.copyWith(
                                        color: AppColors.onSurface,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: task.priority.containerColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  task.priority.label,
                                  style: AppTypography.labelSm.copyWith(
                                    color: task.priority.color,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Time Range Formatted
                              Row(
                                children: [
                                  const Icon(Icons.schedule_rounded, size: 12, color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.timeRangeFormatted,
                                    style: AppTypography.monoTime.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Task Title & Interactive Checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: onToggle,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: isDone ? AppColors.completed : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDone ? AppColors.completed : AppColors.outlineVariant,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isDone
                                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: AppTypography.headlineSm.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        decoration: isDone ? TextDecoration.lineThrough : null,
                                        color: isDone ? AppColors.onSurfaceVariant : AppColors.onSurface,
                                      ),
                                    ),
                                    if (task.description.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        task.description,
                                        style: AppTypography.bodySm.copyWith(
                                          fontSize: 12,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Bottom Row: Progress bar & Subtasks info
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: task.progressPercentage / 100,
                                    minHeight: 5,
                                    backgroundColor: AppColors.surfaceContainerHigh,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDone ? AppColors.completed : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${task.progressPercentage}%',
                                style: AppTypography.labelSm.copyWith(
                                  color: isDone ? AppColors.completed : AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (task.subtasks.isNotEmpty) ...[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.checklist_rounded, size: 12, color: AppColors.onSurfaceVariant),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${task.completedSubtasksCount}/${task.totalSubtasksCount}',
                                        style: AppTypography.monoTime.copyWith(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
