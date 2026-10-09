import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../models/task_model.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/timeline_provider.dart';
import '../../tasks/screens/task_detail_screen.dart';

class TimelineTrackingScreen extends StatelessWidget {
  const TimelineTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timelineProvider = context.watch<TimelineProvider>();
    final taskProvider = context.watch<TaskProvider>();

    final timelineTasks = timelineProvider.filterTasksForTimeline(taskProvider.allTasks);
    final weekDays = timelineProvider.currentWeekDays;

    final List<String> timeFilters = ['Semua', 'Pagi', 'Siang', 'Sore', 'Malam'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header & Live Momentum Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Timeline Pengerjaan', style: AppTypography.headlineSm),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Sinkronisasi otomatis ke cloud',
                            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${taskProvider.inProgressTasksCount} Aktif',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Weekly Calendar Ribbon
            SizedBox(
              height: 76,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: weekDays.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final day = weekDays[index];
                  final isSelected = day.year == timelineProvider.selectedDate.year &&
                      day.month == timelineProvider.selectedDate.month &&
                      day.day == timelineProvider.selectedDate.day;

                  final tasksOnDay = taskProvider.allTasks.where((t) {
                    return t.startTime.year == day.year &&
                        t.startTime.month == day.month &&
                        t.startTime.day == day.day;
                  }).length;

                  return GestureDetector(
                    onTap: () => timelineProvider.setSelectedDate(day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 62 : 54,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.outlineHairline,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormatter.getIndonesianDayName(day),
                            style: AppTypography.labelSm.copyWith(
                              color: isSelected ? AppColors.primaryFixed : AppColors.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            day.day.toString(),
                            style: AppTypography.headlineSm.copyWith(
                              color: isSelected ? Colors.white : AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : (tasksOnDay > 0 ? AppColors.primary : Colors.transparent),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // View Segmented Switcher (Time Filters)
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: timeFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final filter = timeFilters[index];
                  final isSelected = timelineProvider.activeTimeFilter == filter;

                  return ChoiceChip(
                    selected: isSelected,
                    label: Text(filter),
                    labelStyle: AppTypography.labelSm.copyWith(
                      color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    selectedColor: AppColors.onSurface,
                    backgroundColor: AppColors.surfaceContainerLowest,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    showCheckmark: false,
                    onSelected: (_) => timelineProvider.setTimeFilter(filter),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Timeline Spine & Task Nodes
            Expanded(
              child: timelineTasks.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timeline_rounded, size: 48, color: AppColors.outline),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak Ada Jadwal Timeline',
                              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Belum ada tugas terjadwal pada hari atau filter waktu ini.',
                              style: AppTypography.bodySm,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: timelineTasks.length,
                      itemBuilder: (context, index) {
                        final task = timelineTasks[index];
                        final isLast = index == timelineTasks.length - 1;

                        return _buildTimelineRow(context, task, isLast);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineRow(BuildContext context, TaskModel task, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 56px Left Rail (Spine + Milestone Node)
          SizedBox(
            width: 56,
            child: Column(
              children: [
                // Milestone Node
                _buildMilestoneNode(task),
                // Vertical Connecting Spine
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.outlineHairline,
                    ),
                  ),
              ],
            ),
          ),

          // Fluid Task Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailScreen(taskId: task.id),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: task.isCompleted ? AppColors.completed.withValues(alpha: 0.3) : AppColors.outlineHairline,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time badge & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 12, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  task.timeRangeFormatted,
                                  style: AppTypography.monoTime.copyWith(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: task.status.containerColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task.status.label,
                              style: AppTypography.labelSm.copyWith(
                                color: task.status.color,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        task.title,
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Progress bar with indicator
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: task.progressPercentage / 100,
                                minHeight: 6,
                                backgroundColor: AppColors.surfaceContainerHigh,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  task.isCompleted ? AppColors.completed : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${task.progressPercentage}%',
                            style: AppTypography.monoTime.copyWith(
                              fontSize: 11,
                              color: task.isCompleted ? AppColors.completed : AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneNode(TaskModel task) {
    if (task.isCompleted) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.completed,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
      );
    }

    if (task.status == TaskStatus.IN_PROGRESS) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: SizedBox(
            width: 8,
            height: 8,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    // Default TODO Milestone node
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outlineVariant, width: 2),
      ),
    );
  }
}
