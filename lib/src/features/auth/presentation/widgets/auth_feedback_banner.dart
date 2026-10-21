import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Displays an inline alert banner for authentication feedback or error messages.
class AuthFeedbackBanner extends StatelessWidget {
  /// Creates an [AuthFeedbackBanner].
  const AuthFeedbackBanner({
    required this.message,
    required this.isError,
    super.key,
  });

  /// Text message to display inside the banner.
  final String message;

  /// Whether the banner represents an error (`true`) or informational success (`false`).
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final accentColor = isError ? AppColors.rose500 : AppColors.emerald500;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: accentColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

