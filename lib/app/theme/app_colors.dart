import 'package:flutter/material.dart';

class AppColors {
  // Canvas & Surfaces (Material 3 Dynamic Surface Specs)
  static const Color surface = Color(0xFFF8F9FF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surfaceDim = Color(0xFFCBDBF5);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);

  // Brand Primaries & Secondaries
  static const Color primary = Color(0xFF3525CD);
  static const Color primaryContainer = Color(0xFF4F46E5);
  static const Color primaryFixed = Color(0xFFE2DFFF);
  static const Color primaryFixedDim = Color(0xFFC3C0FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryFixed = Color(0xFF0F0069);
  static const Color onPrimaryContainer = Color(0xFFDAD7FF);

  static const Color secondary = Color(0xFF4648D4);
  static const Color secondaryContainer = Color(0xFF6063EE);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFFFFFBFF);

  // Typography & On-Surfaces
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF464555);
  static const Color outline = Color(0xFF777587);
  static const Color outlineVariant = Color(0xFFC7C4D8);
  static const Color outlineHairline = Color(0xFFE2E8F0);

  // Semantic Priorities & Statuses
  static const Color urgent = Color(0xFFF43F5E); // Urgent / High
  static const Color urgentContainer = Color(0xFFFFF1F2);
  static const Color inProgress = Color(0xFFF59E0B); // Amber / In Progress
  static const Color inProgressContainer = Color(0xFFFFFBEB);
  static const Color completed = Color(0xFF10B981); // Emerald / Completed
  static const Color completedContainer = Color(0xFFECFDF5);
  static const Color todo = Color(0xFF64748B); // Slate / Todo
  static const Color todoContainer = Color(0xFFF1F5F9);
  static const Color blocked = Color(0xFF9333EA); // Purple / Blocked
  static const Color blockedContainer = Color(0xFFFAF5FF);

  // Error States
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3525CD), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient kineticGlowGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF6063EE), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardAccentGradient = LinearGradient(
    colors: [Color(0xFFE2DFFF), Color(0xFFEFF4FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
