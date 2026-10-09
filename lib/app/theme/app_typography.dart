import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const String fontHeading = 'Plus Jakarta Sans';
  static const String fontBody = 'Inter';

  static const TextStyle headlineXl = TextStyle(
    fontFamily: fontHeading,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.64,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: fontHeading,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 34 / 26,
    letterSpacing: -0.39,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: fontHeading,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: -0.2,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: fontHeading,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 24 / 17,
    letterSpacing: -0.085,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    letterSpacing: 0.065,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: fontHeading,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 18 / 13,
    letterSpacing: 0.13,
    color: AppColors.onSurface,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: fontHeading,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 14 / 11,
    letterSpacing: 0.22,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle monoTime = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: -0.12,
    fontFeatures: [FontFeature.tabularFigures()],
    color: AppColors.onSurfaceVariant,
  );
}
