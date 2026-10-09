import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../models/focus_session_model.dart';
import '../../../providers/focus_timer_provider.dart';
import '../../../providers/task_provider.dart';

class KineticFocusScreen extends StatefulWidget {
  const KineticFocusScreen({super.key});

  @override
  State<KineticFocusScreen> createState() => _KineticFocusScreenState();
}

class _KineticFocusScreenState extends State<KineticFocusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _ambientSound = 'Mute';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = context.watch<FocusTimerProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final boundTask = timerProvider.boundTask;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Kinetic Focus OS', style: AppTypography.headlineSm),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Sesi ${timerProvider.completedSessionsToday + 1} dari ${timerProvider.sessionGoal}',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.onPrimaryFixed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          child: Column(
            children: [
              // Active Task Focus Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineHairline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fokus Pada Tugas:', style: AppTypography.labelSm),
                          const SizedBox(height: 2),
                          Text(
                            boundTask?.title ?? 'Fokus Bebas (Deep Work)',
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
                      tooltip: 'Ganti Tugas',
                      onSelected: (taskId) {
                        final selected = taskProvider.allTasks.firstWhere((t) => t.id == taskId);
                        timerProvider.bindTask(selected);
                        SnackBarHelper.showInfo(context, 'Fokus dialihkan ke "${selected.title}"');
                      },
                      itemBuilder: (ctx) {
                        return taskProvider.allTasks.map((t) {
                          return PopupMenuItem(
                            value: t.id,
                            child: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Mode Selector Segmented Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: FocusMode.values.map((mode) {
                  final isSelected = timerProvider.currentMode == mode;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text('${mode.label} (${mode.defaultMinutes}m)'),
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
                      showCheckmark: false,
                      onSelected: (_) => timerProvider.setMode(mode),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Kinetic Breathing & Pulsing Circular Timer Animation
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final isRunning = timerProvider.timerState == TimerState.running;
                  final scale = isRunning ? _pulseAnimation.value : 1.0;

                  return Transform.scale(
                    scale: scale,
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ambient Glow Halo
                          if (isRunning)
                            Container(
                              width: 230,
                              height: 230,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.18),
                                    blurRadius: 36,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                            ),

                          // Background Track
                          const SizedBox(
                            width: 220,
                            height: 220,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 8,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.surfaceContainerHigh,
                              ),
                            ),
                          ),

                          // Dynamic Gradient Progress Fill
                          SizedBox(
                            width: 220,
                            height: 220,
                            child: CircularProgressIndicator(
                              value: timerProvider.progressRatio,
                              strokeWidth: 9,
                              strokeCap: StrokeCap.round,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                timerProvider.currentMode == FocusMode.focus
                                    ? AppColors.primary
                                    : AppColors.completed,
                              ),
                            ),
                          ),

                          // Inner Digital Counter & Label
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                timerProvider.formattedTime,
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontHeading,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1.0,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isRunning ? 'MOMENTUM AKTIF' : 'SIAP MEMULAI',
                                  style: AppTypography.labelSm.copyWith(
                                    color: isRunning ? AppColors.primary : AppColors.onSurfaceVariant,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 36),

              // Control Actions (Play/Pause, Reset, Ambient Sound)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset Button
                  IconButton.filledTonal(
                    onPressed: timerProvider.resetTimer,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Reset',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerLowest,
                      foregroundColor: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Main Play/Pause FAB
                  GestureDetector(
                    onTap: () {
                      if (timerProvider.timerState == TimerState.running) {
                        timerProvider.pauseTimer();
                      } else {
                        timerProvider.startTimer();
                      }
                    },
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        timerProvider.timerState == TimerState.running
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Ambient Noise Toggle
                  PopupMenuButton<String>(
                    tooltip: 'Suara Relaksasi',
                    icon: const Icon(Icons.waves_rounded, color: AppColors.onSurfaceVariant),
                    onSelected: (sound) {
                      setState(() => _ambientSound = sound);
                      SnackBarHelper.showInfo(context, 'Suara fokus: $sound');
                    },
                    itemBuilder: (ctx) => ['Mute', 'Hujan Deras', 'Kafe Kopi', 'White Noise', 'Sungai Alami']
                        .map((s) => PopupMenuItem(value: s, child: Text(s)))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Focus Session Metrics Bento
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineHairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Statistik Fokus Hari Ini', style: AppTypography.labelMd),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFocusStat(
                            'Total Waktu',
                            '${timerProvider.totalFocusMinutesToday} m',
                            Icons.timelapse_rounded,
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFocusStat(
                            'Sesi Selesai',
                            '${timerProvider.completedSessionsToday}',
                            Icons.check_circle_outline_rounded,
                            AppColors.completed,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFocusStat(
                            'Efisiensi',
                            '96%',
                            Icons.trending_up_rounded,
                            AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFocusStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(label, style: AppTypography.labelSm.copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.headlineSm.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
