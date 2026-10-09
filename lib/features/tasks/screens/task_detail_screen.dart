import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../models/task_model.dart';
import '../../../models/timeline_log_model.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/focus_timer_provider.dart';
import '../../kinetic_focus/screens/kinetic_focus_screen.dart';
import '../../../shared/widgets/app_button.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  List<TimelineLogModel> _logs = [];
  bool _isLoadingLogs = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final taskProvider = context.read<TaskProvider>();
    final logs = await taskProvider.getTaskTimelineLogs(widget.taskId);
    if (mounted) {
      setState(() {
        _logs = logs;
        _isLoadingLogs = false;
      });
    }
  }

  void _showAddProgressLogDialog(TaskModel task) {
    int newPercentage = task.progressPercentage;
    TaskStatus newStatus = task.status;
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Catat Log Progres Timeline', style: AppTypography.headlineSm),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Update Persentase: $newPercentage%', style: AppTypography.labelMd),
                  Slider(
                    value: newPercentage.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setModalState(() {
                        newPercentage = val.round();
                        if (newPercentage == 100) {
                          newStatus = TaskStatus.COMPLETED;
                        } else if (newPercentage > 0 && newStatus == TaskStatus.TODO) {
                          newStatus = TaskStatus.IN_PROGRESS;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text('Status Baru:', style: AppTypography.labelMd),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<TaskStatus>(
                    initialValue: newStatus,
                    items: TaskStatus.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.label, style: AppTypography.bodyMd),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => newStatus = val);
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    style: AppTypography.bodyMd,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan catatan milestone atau perubahan...',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Simpan Log Timeline',
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final taskProvider = context.read<TaskProvider>();
                      await taskProvider.updateTaskProgress(
                        taskId: task.id,
                        progressPercentage: newPercentage,
                        status: newStatus,
                        note: noteController.text.trim().isNotEmpty
                            ? noteController.text.trim()
                            : null,
                      );
                      _loadLogs();
                      if (mounted) {
                        SnackBarHelper.showSuccess(context, 'Log timeline berhasil diperbarui.');
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final taskIndex = taskProvider.allTasks.indexWhere((t) => t.id == widget.taskId);

    if (taskIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tugas')),
        body: const Center(child: Text('Tugas tidak ditemukan.')),
      );
    }

    final task = taskProvider.allTasks[taskIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Tugas', style: AppTypography.headlineSm),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => SnackBarHelper.showInfo(context, 'Tautan tugas disalin ke papan klip.'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category & Priority Badges
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          task.categoryName,
                          style: AppTypography.labelSm.copyWith(color: AppColors.onPrimaryFixed),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: task.priority.containerColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      task.priority.label,
                      style: AppTypography.labelSm.copyWith(
                        color: task.priority.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Sync Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          task.isPendingSync ? Icons.cloud_upload_outlined : Icons.cloud_done_rounded,
                          size: 14,
                          color: task.isPendingSync ? AppColors.inProgress : AppColors.completed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.isPendingSync ? 'Pending Sync' : 'Synced',
                          style: AppTypography.monoTime.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                task.title,
                style: AppTypography.headlineLg.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 16),

              // Interactive Status Selector Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineHairline),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: task.status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Status Pekerjaan', style: AppTypography.labelSm),
                          Text(task.status.label, style: AppTypography.labelMd.copyWith(color: task.status.color)),
                        ],
                      ),
                    ),
                    DropdownButton<TaskStatus>(
                      value: task.status,
                      underline: const SizedBox(),
                      items: TaskStatus.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s.label, style: AppTypography.labelSm.copyWith(color: s.color)),
                        );
                      }).toList(),
                      onChanged: (newStatus) {
                        if (newStatus != null) {
                          taskProvider.updateTaskProgress(
                            taskId: task.id,
                            progressPercentage: newStatus == TaskStatus.COMPLETED ? 100 : task.progressPercentage,
                            status: newStatus,
                            note: 'Status diubah ke ${newStatus.label}',
                          );
                          _loadLogs();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Schedule Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Jadwal: ${DateFormatter.formatDate(task.startTime)} (${task.timeRangeFormatted})',
                        style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Progress Percentage & Slider Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineHairline),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tracking Progres', style: AppTypography.labelMd),
                        Text(
                          '${task.progressPercentage}%',
                          style: AppTypography.headlineSm.copyWith(
                            color: task.isCompleted ? AppColors.completed : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: task.progressPercentage / 100,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          task.isCompleted ? AppColors.completed : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showAddProgressLogDialog(task),
                          icon: const Icon(Icons.edit_note_rounded, size: 18),
                          label: const Text('Catat Progres Baru'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Description Details Card
              if (task.description.isNotEmpty) ...[
                const Text('Deskripsi Tugas', style: AppTypography.labelMd),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outlineHairline),
                  ),
                  child: Text(
                    task.description,
                    style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Subtasks Checklist
              if (task.subtasks.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtugas Target', style: AppTypography.labelMd),
                    Text(
                      '${task.completedSubtasksCount}/${task.totalSubtasksCount} selesai',
                      style: AppTypography.monoTime,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineHairline),
                  ),
                  child: Column(
                    children: task.subtasks.map((st) {
                      return CheckboxListTile(
                        value: st.isCompleted,
                        title: Text(
                          st.title,
                          style: AppTypography.bodySm.copyWith(
                            decoration: st.isCompleted ? TextDecoration.lineThrough : null,
                            color: st.isCompleted ? AppColors.onSurfaceVariant : AppColors.onSurface,
                          ),
                        ),
                        activeColor: AppColors.completed,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        onChanged: (_) {
                          taskProvider.toggleSubtask(task.id, st.id);
                          _loadLogs();
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Historis Timeline Logs Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Historis Log Timeline', style: AppTypography.labelMd),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
                    onPressed: () => _showAddProgressLogDialog(task),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_isLoadingLogs)
                const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
              else if (_logs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: const Text('Belum ada log aktivitas timeline.', style: AppTypography.bodySm),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineHairline),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _logs.length,
                    separatorBuilder: (_, __) => const Divider(height: 24, color: AppColors.outlineHairline),
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      log.newStatus,
                                      style: AppTypography.labelSm.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormatter.formatTime(log.recordedAt),
                                      style: AppTypography.monoTime.copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                                if (log.note != null && log.note!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    log.note!,
                                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),

              // Sticky Bottom Actions: Kinetic Focus & Selesai
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Bind this task to focus timer
                        context.read<FocusTimerProvider>().bindTask(task);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KineticFocusScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.timer_outlined, size: 18, color: AppColors.primary),
                      label: const Text('Kinetic Focus'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: task.isCompleted ? 'Buka Kembali' : 'Tandai Selesai',
                      onPressed: () {
                        taskProvider.toggleTaskCompletion(task.id);
                        _loadLogs();
                        SnackBarHelper.showSuccess(
                          context,
                          task.isCompleted ? 'Tugas dibuka kembali.' : 'Tugas berhasil diselesaikan 100%!',
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
