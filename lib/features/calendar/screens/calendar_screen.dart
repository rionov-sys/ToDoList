import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../models/task_model.dart';
import '../../../providers/calendar_provider.dart';
import '../../../providers/task_provider.dart';
import '../../tasks/screens/create_task_screen.dart';
import '../../tasks/screens/task_detail_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calendarProvider = context.watch<CalendarProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final allTasks = taskProvider.allTasks;

    final agendaTasks = calendarProvider.getAgendaTasksForSelectedDay(allTasks);
    final currentMonth = calendarProvider.currentMonth;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header & Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: calendarProvider.prevMonth,
                      ),
                      Text(
                        DateFormatter.formatMonthYear(currentMonth),
                        style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: calendarProvider.nextMonth,
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: calendarProvider.selectToday,
                    icon: const Icon(Icons.restart_alt_rounded, size: 16),
                    label: const Text('Hari Ini'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // View Mode Switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _buildModeButton(context, 'Bulan', CalendarViewMode.month, calendarProvider),
                    _buildModeButton(context, 'Minggu', CalendarViewMode.week, calendarProvider),
                    _buildModeButton(context, 'Agenda', CalendarViewMode.agenda, calendarProvider),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Monthly Summary Metric Banner (Isar Local Sync Telemetry)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.sync_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Sinkron ke Isar Local DB',
                              style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
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
                            const SizedBox(width: 4),
                            Text(
                              'Realtime',
                              style: AppTypography.monoTime.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBannerStat(
                            'Total Tugas',
                            allTasks.length.toString(),
                            AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildBannerStat(
                            'Selesai',
                            taskProvider.completedTasksCount.toString(),
                            AppColors.completed,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildBannerStat(
                            'Tertunda',
                            taskProvider.urgentTasksCount.toString(),
                            AppColors.urgent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Calendar Grid (Month View)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineHairline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Weekday Labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                          .map((d) => SizedBox(
                                width: 36,
                                child: Center(
                                  child: Text(
                                    d,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontHeading,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 10),

                    // Calendar Day Cells
                    _buildMonthGrid(context, calendarProvider, allTasks),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Day Agenda Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Agenda: ${DateFormatter.formatDate(calendarProvider.selectedDay)}',
                    style: AppTypography.headlineSm.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${agendaTasks.length} tugas',
                    style: AppTypography.monoTime.copyWith(color: AppColors.outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Daily Agenda Items
              if (agendaTasks.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineHairline),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.event_available_rounded, size: 36, color: AppColors.outline),
                        const SizedBox(height: 8),
                        Text('Tidak ada agenda untuk tanggal ini.', style: AppTypography.bodySm),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
                            );
                          },
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Tambah Tugas'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: agendaTasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = agendaTasks[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id)),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.outlineHairline),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 36,
                              decoration: BoxDecoration(
                                color: task.priority.color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: AppTypography.bodyMd.copyWith(
                                      fontWeight: FontWeight.w600,
                                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${task.timeRangeFormatted} • ${task.categoryName}',
                                    style: AppTypography.monoTime.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: task.isCompleted,
                              activeColor: AppColors.completed,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (_) {
                                taskProvider.toggleTaskCompletion(task.id);
                                SnackBarHelper.showSuccess(
                                  context,
                                  task.isCompleted ? 'Tugas dibuka kembali.' : 'Tugas diselesaikan!',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(BuildContext context, String title, CalendarViewMode mode, CalendarProvider provider) {
    final isSelected = provider.viewMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setViewMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: AppTypography.labelSm.copyWith(
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSm.copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.headlineSm.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(BuildContext context, CalendarProvider provider, List<TaskModel> allTasks) {
    final month = provider.currentMonth;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    final totalSlots = ((startingWeekday - 1) + daysInMonth <= 35) ? 35 : 42;
    final now = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalSlots,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final dayOffset = index - (startingWeekday - 1);
        if (dayOffset < 0 || dayOffset >= daysInMonth) {
          return const SizedBox.shrink();
        }

        final dayNumber = dayOffset + 1;
        final date = DateTime(month.year, month.month, dayNumber);

        final isSelected = date.year == provider.selectedDay.year &&
            date.month == provider.selectedDay.month &&
            date.day == provider.selectedDay.day;

        final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

        final tasksOnThisDay = allTasks.where((t) {
          return t.startTime.year == date.year &&
              t.startTime.month == date.month &&
              t.startTime.day == date.day;
        }).toList();

        return GestureDetector(
          onTap: () => provider.selectDay(date),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isToday ? AppColors.primaryFixed.withOpacity(0.4) : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayNumber.toString(),
                  style: AppTypography.labelMd.copyWith(
                    color: isSelected ? Colors.white : AppColors.onSurface,
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                if (tasksOnThisDay.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }
}
