import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class BentoMomentumCard extends StatelessWidget {
  final int percentage;
  final int inProgressCount;
  final int urgentCount;
  final int completedCount;

  const BentoMomentumCard({
    super.key,
    required this.percentage,
    required this.inProgressCount,
    required this.urgentCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineHairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top Row: Progress Ring & Focus Description
          Row(
            children: [
              // Circular Progress Ring
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                    ),
                    Text(
                      '$percentage%',
                      style: AppTypography.headlineSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fokus Hari Ini',
                      style: AppTypography.headlineSm.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      percentage >= 70
                          ? 'Momentum luar biasa, target tercapai!'
                          : 'Progres stabil, lanjutkan fokus.',
                      style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  percentage >= 50 ? 'On Track' : 'Needs Focus',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Column Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.motion_photos_on_rounded,
                  label: 'Berjalan',
                  value: inProgressCount.toString(),
                  iconColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceContainerLow,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.priority_high_rounded,
                  label: 'Urgent',
                  value: urgentCount.toString(),
                  iconColor: AppColors.urgent,
                  backgroundColor: AppColors.urgentContainer,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.check_circle_rounded,
                  label: 'Selesai',
                  value: completedCount.toString(),
                  iconColor: AppColors.completed,
                  backgroundColor: AppColors.completedContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSm.copyWith(
                    color: iconColor,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
