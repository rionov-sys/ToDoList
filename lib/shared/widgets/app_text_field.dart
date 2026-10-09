import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool showClearButton;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.onClear,
    this.showClearButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label!,
              style: AppTypography.labelMd.copyWith(color: AppColors.onSurface),
            ),
          ),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
            errorText: errorText,
            helperText: helperText,
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.onSurfaceVariant, size: 20)
                : null,
            suffixIcon: showClearButton && controller != null && controller!.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.onSurfaceVariant,
                    onPressed: () {
                      controller?.clear();
                      onClear?.call();
                    },
                  )
                : suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineHairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineHairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
