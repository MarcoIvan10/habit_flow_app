import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Displays an informational banner when Supabase credentials are not configured
/// and the application is running in local demo mode.
class SupabaseModeBanner extends StatelessWidget {
  /// Creates a [SupabaseModeBanner].
  const SupabaseModeBanner({
    required this.isSupabaseConfigured,
    super.key,
  });

  /// Indicates whether Supabase credentials are configured.
  final bool isSupabaseConfigured;

  @override
  Widget build(BuildContext context) {
    if (isSupabaseConfigured) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.amber500.withValues(alpha: 0.14)
            : AppColors.amber500.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.amber500.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.amber500,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Modo Demo Local activo: Configura SUPABASE_URL y SUPABASE_ANON_KEY en el archivo .env para sincronizar con PostgreSQL.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
