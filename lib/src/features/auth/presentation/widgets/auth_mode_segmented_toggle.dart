import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/enums/auth_form_mode.dart';

/// Renders a two-option segmented control for switching between sign-in and sign-up modes.
class AuthModeSegmentedToggle extends StatelessWidget {
  /// Creates an [AuthModeSegmentedToggle] instance.
  const AuthModeSegmentedToggle({
    super.key,
    required this.currentMode,
    required this.enabled,
    required this.onChanged,
  });

  /// Currently selected authentication form mode.
  final AuthFormMode currentMode;

  /// Whether user interaction is enabled.
  final bool enabled;

  /// Callback invoked when the user selects a mode.
  final ValueChanged<AuthFormMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.slate950.withValues(alpha: 0.7)
            : AppColors.slate50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.slate800 : AppColors.slate200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeOptionButton(
              label: 'Iniciar sesión',
              isSelected: currentMode == AuthFormMode.signIn,
              isDark: isDark,
              onTap: enabled ? () => onChanged(AuthFormMode.signIn) : null,
            ),
          ),
          Expanded(
            child: _ModeOptionButton(
              label: 'Crear cuenta',
              isSelected: currentMode == AuthFormMode.signUp,
              isDark: isDark,
              onTap: enabled ? () => onChanged(AuthFormMode.signUp) : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal button representing a single option inside [AuthModeSegmentedToggle].
class _ModeOptionButton extends StatelessWidget {
  /// Creates a [_ModeOptionButton] instance.
  const _ModeOptionButton({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  /// Visible button label.
  final String label;

  /// Whether this option is currently active.
  final bool isSelected;

  /// Whether dark theme styling is active.
  final bool isDark;

  /// Tap callback when interactive.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.slate900 : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : AppColors.slate900)
                : (isDark ? AppColors.slate400 : AppColors.slate500),
          ),
        ),
      ),
    );
  }
}
