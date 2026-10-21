import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Displays an error state card with a retry button when loading dashboard data fails.
class DashboardErrorView extends StatelessWidget {
  /// Creates a [DashboardErrorView].
  const DashboardErrorView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  /// User-facing error message explaining the failure.
  final String message;

  /// Callback invoked when the user presses the retry button.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.rose500.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      color: AppColors.rose500,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pudimos cargar tus hábitos',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.slate500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

