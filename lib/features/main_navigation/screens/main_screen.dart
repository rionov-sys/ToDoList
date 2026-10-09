import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../providers/auth_provider.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../kinetic_focus/screens/kinetic_focus_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../tasks/screens/create_task_screen.dart';
import '../../tasks/screens/task_list_screen.dart';
import '../../timeline/screens/timeline_tracking_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TaskListScreen(),
    TimelineTrackingScreen(),
    KineticFocusScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            border: const Border(bottom: BorderSide(color: AppColors.outlineHairline)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // App Icon Logo
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Chronos',
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'OS v1.0',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.onPrimaryFixed,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _getScreenSubtitle(_currentIndex),
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Notifications Icon
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined, size: 22, color: AppColors.onSurfaceVariant),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.urgent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      SnackBarHelper.showInfo(context, 'Pemberitahuan: 1 tugas deadline mendekat.');
                    },
                  ),

                  // Avatar / Profile Shortcut
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 4),
                    child: Container(
                      width: 34,
                      height: 34,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        border: _currentIndex == 4
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          user?.initials ?? 'AK',
                          style: AppTypography.labelSm.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppColors.surfaceContainerLowest,
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Navigation Items
            Row(
              children: [
                _buildNavItem(0, Icons.task_alt_rounded, 'Tugas'),
                const SizedBox(width: 4),
                _buildNavItem(1, Icons.timeline_rounded, 'Timeline'),
              ],
            ),
            // Middle Notch Spacer for FAB
            const SizedBox(width: 48),
            // Right Navigation Items
            Row(
              children: [
                _buildNavItem(2, Icons.timer_outlined, 'Fokus'),
                const SizedBox(width: 4),
                _buildNavItem(3, Icons.calendar_month_rounded, 'Kalender'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _currentIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getScreenSubtitle(int index) {
    switch (index) {
      case 0:
        return 'Daftar Tugas & Prioritas';
      case 1:
        return 'Pelacakan Timeline';
      case 2:
        return 'Kinetic Focus Timer';
      case 3:
        return 'Agenda & Kalender';
      case 4:
        return 'Pusat Kendali Akun';
      default:
        return '';
    }
  }
}
