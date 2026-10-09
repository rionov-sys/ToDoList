import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../models/task_model.dart';
import '../../../providers/task_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController(text: 'Implementasi BLoC State & Offline Cache');
  final _descController = TextEditingController();
  final _subtaskInputController = TextEditingController();

  String _selectedCategory = 'Work';
  String _categoryColorHex = '#4F46E5';
  TaskPriority _selectedPriority = TaskPriority.urgent;
  
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;

  int _progress = 0;
  final bool _isRecurring = false;
  bool _isLoading = false;

  final List<SubTaskModel> _subtasks = [
    const SubTaskModel(id: 's_1', title: 'Setup BLoC Observer & State Machine', isCompleted: false),
    const SubTaskModel(id: 's_2', title: 'Implementasi Local Cache Repository', isCompleted: false),
  ];

  final List<Map<String, String>> _availableCategories = [
    {'name': 'Work', 'color': '#4F46E5'},
    {'name': 'Study', 'color': '#4648D4'},
    {'name': 'Personal', 'color': '#10B981'},
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = now;
    _startTime = const TimeOfDay(hour: 9, minute: 0);
    _dueDate = now;
    _dueTime = const TimeOfDay(hour: 11, minute: 30);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subtaskInputController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _dueDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _dueTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _dueTime = picked;
        }
      });
    }
  }

  void _addSubtask() {
    final title = _subtaskInputController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _subtasks.add(
        SubTaskModel(
          id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          isCompleted: false,
        ),
      );
      _subtaskInputController.clear();
    });
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      SnackBarHelper.showError(context, 'Judul tugas wajib diisi!');
      return;
    }

    setState(() => _isLoading = true);

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final dueDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    final newTask = TaskModel(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'usr_demo_1',
      categoryId: 'cat_${_selectedCategory.toLowerCase()}',
      categoryName: _selectedCategory,
      categoryColorHex: _categoryColorHex,
      title: title,
      description: _descController.text.trim(),
      status: _progress == 100
          ? TaskStatus.completed
          : (_progress > 0 ? TaskStatus.inProgress : TaskStatus.todo),
      priority: _selectedPriority,
      progressPercentage: _progress,
      startTime: startDateTime,
      dueTime: dueDateTime,
      isRecurring: _isRecurring,
      subtasks: _subtasks,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final taskProvider = context.read<TaskProvider>();
    final success = await taskProvider.addTask(newTask);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      SnackBarHelper.showSuccess(context, 'Tugas "$title" berhasil disimpan!');
      Navigator.pop(context);
    } else {
      SnackBarHelper.showError(
        context,
        taskProvider.errorMessage ?? 'Gagal menyimpan tugas. Cek koneksi.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Tugas Baru', style: AppTypography.headlineSm),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
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
              // Micro-action Header: Isar Local DB Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
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
                          'Tersimpan otomatis di Isar Local DB',
                          style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => SnackBarHelper.showInfo(context, 'Draft tugas disimpan sementara.'),
                    child: Text('Simpan Draft', style: AppTypography.labelSm.copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title Field
              AppTextField(
                controller: _titleController,
                label: 'Judul Tugas',
                hintText: 'e.g. Implementasi BLoC State & Offline Cache',
                showClearButton: true,
              ),
              const SizedBox(height: 16),

              // Categories Chips
              const Text('Kategori & Tag', style: AppTypography.labelMd),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ..._availableCategories.map((cat) {
                    final isSelected = _selectedCategory == cat['name'];
                    return ChoiceChip(
                      selected: isSelected,
                      label: Text(cat['name']!),
                      labelStyle: AppTypography.labelSm.copyWith(
                        color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.outlineHairline,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat['name']!;
                            _categoryColorHex = cat['color']!;
                          });
                        }
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),

              // Priority Selector Pills
              const Text('Tingkat Prioritas', style: AppTypography.labelMd),
              const SizedBox(height: 8),
              Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPriority = priority),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? priority.color : priority.containerColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? priority.color : priority.color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              priority.label,
                              style: AppTypography.labelSm.copyWith(
                                color: isSelected ? Colors.white : priority.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Date & Time Scheduling Cards
              const Text('Jadwal Pengerjaan (Timeline)', style: AppTypography.labelMd),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineHairline),
                ),
                child: Column(
                  children: [
                    // Start Time Row
                    Row(
                      children: [
                        const Icon(Icons.play_circle_outline_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        const Text('Mulai:', style: AppTypography.bodySm),
                        const Spacer(),
                        InkWell(
                          onTap: () => _pickDate(isStart: true),
                          child: Chip(
                            label: Text(DateFormatter.formatShortDate(_startDate)),
                            labelStyle: AppTypography.labelSm,
                            backgroundColor: AppColors.surfaceContainerLow,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _pickTime(isStart: true),
                          child: Chip(
                            label: Text('${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}'),
                            labelStyle: AppTypography.monoTime,
                            backgroundColor: AppColors.surfaceContainerLow,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: AppColors.outlineHairline),
                    // Due Time Row
                    Row(
                      children: [
                        const Icon(Icons.flag_outlined, color: AppColors.urgent, size: 20),
                        const SizedBox(width: 8),
                        const Text('Deadline:', style: AppTypography.bodySm),
                        const Spacer(),
                        InkWell(
                          onTap: () => _pickDate(isStart: false),
                          child: Chip(
                            label: Text(DateFormatter.formatShortDate(_dueDate)),
                            labelStyle: AppTypography.labelSm,
                            backgroundColor: AppColors.surfaceContainerLow,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _pickTime(isStart: false),
                          child: Chip(
                            label: Text('${_dueTime.hour.toString().padLeft(2, '0')}:${_dueTime.minute.toString().padLeft(2, '0')}'),
                            labelStyle: AppTypography.monoTime,
                            backgroundColor: AppColors.surfaceContainerLow,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Description Textarea
              AppTextField(
                controller: _descController,
                label: 'Catatan & Detail',
                hintText: 'Tambahkan instruksi spesifik atau tautan dokumen...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Subtasks Checklist Builder
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtugas (${_subtasks.length})', style: AppTypography.labelMd),
                  const Text('Opsional', style: AppTypography.bodySm),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineHairline),
                ),
                child: Column(
                  children: [
                    ..._subtasks.map((st) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_box_outline_blank_rounded, size: 18, color: AppColors.outline),
                            const SizedBox(width: 8),
                            Expanded(child: Text(st.title, style: AppTypography.bodySm)),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.urgent),
                              onPressed: () => setState(() => _subtasks.remove(st)),
                            ),
                          ],
                        ),
                      );
                    }),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _subtaskInputController,
                            style: AppTypography.bodySm,
                            decoration: const InputDecoration(
                              hintText: 'Tambah subtugas baru...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            onSubmitted: (_) => _addSubtask(),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: _addSubtask,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Initial Progress Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progres Awal: $_progress%', style: AppTypography.labelMd),
                  Text(
                    _progress == 100 ? 'Selesai' : (_progress > 0 ? 'Berjalan' : 'Belum Mulai'),
                    style: AppTypography.labelSm.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              Slider(
                value: _progress.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.surfaceContainerHigh,
                onChanged: (val) => setState(() => _progress = val.round()),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Batal',
                      variant: AppButtonVariant.outline,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: 'Simpan Tugas',
                      isLoading: _isLoading,
                      onPressed: _saveTask,
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
