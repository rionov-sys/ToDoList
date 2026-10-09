import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../providers/task_provider.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../widgets/bento_momentum_card.dart';
import '../widgets/task_card.dart';
import 'create_task_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'Semua'},
    {'id': 'cat_work', 'label': 'Work'},
    {'id': 'cat_study', 'label': 'Study'},
    {'id': 'cat_personal', 'label': 'Personal'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.filteredTasks;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceContainerLowest,
          onRefresh: () async {
            await taskProvider.triggerManualSync();
            if (mounted) {
              SnackBarHelper.showSuccess(context, 'Data tugas berhasil disinkronkan.');
            }
          },
          child: CustomScrollView(
            slivers: [
              // Top Greeting Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hari ini, ${DateFormatter.formatDate(now)}',
                            style: AppTypography.headlineSm.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${taskProvider.completedTasksCount} dari ${taskProvider.totalTasksCount} tugas selesai (${taskProvider.momentumPercentage}%)',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bento Momentum Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BentoMomentumCard(
                    percentage: taskProvider.momentumPercentage,
                    inProgressCount: taskProvider.inProgressTasksCount,
                    urgentCount: taskProvider.urgentTasksCount,
                    completedCount: taskProvider.completedTasksCount,
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.outlineHairline),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => taskProvider.setSearchQuery(val),
                      style: AppTypography.bodyMd,
                      decoration: InputDecoration(
                        hintText: 'Cari tugas, catatan, atau tag...',
                        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  taskProvider.setSearchQuery('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ),

              // Horizontal Category Filter Chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = taskProvider.selectedCategory == cat['id'];

                      return FilterChip(
                        selected: isSelected,
                        label: Text(cat['label']!),
                        labelStyle: AppTypography.labelSm.copyWith(
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: AppColors.surfaceContainerLowest,
                        selectedColor: AppColors.primary,
                        checkmarkColor: Colors.white,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.outlineHairline,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        onSelected: (_) => taskProvider.setCategoryFilter(cat['id']!),
                      );
                    },
                  ),
                ),
              ),

              // Task List Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Prioritas',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${tasks.length} item',
                        style: AppTypography.monoTime.copyWith(color: AppColors.outline),
                      ),
                    ],
                  ),
                ),
              ),

              // Tasks List Items or Empty State
              if (tasks.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    icon: Icons.checklist_rtl_rounded,
                    title: 'Tidak Ada Tugas',
                    description: taskProvider.searchQuery.isNotEmpty
                        ? 'Tidak ada tugas yang cocok dengan "${taskProvider.searchQuery}".'
                        : 'Semua target selesai atau belum ada tugas di kategori ini.',
                    actionText: 'Buat Tugas Baru',
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
                      );
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = tasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailScreen(taskId: task.id),
                              ),
                            );
                          },
                          onToggle: () {
                            taskProvider.toggleTaskCompletion(task.id);
                            SnackBarHelper.showSuccess(
                              context,
                              task.isCompleted
                                  ? 'Tugas "${task.title}" dibuka kembali.'
                                  : 'Tugas "${task.title}" berhasil diselesaikan!',
                            );
                          },
                          onDelete: () {
                            taskProvider.deleteTask(task.id);
                            SnackBarHelper.showInfo(context, 'Tugas telah dihapus.');
                          },
                        );
                      },
                      childCount: tasks.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
