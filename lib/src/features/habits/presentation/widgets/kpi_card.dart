import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Displays an individual KPI metric card with an icon badge, headline value,
/// optional animated progress bar, and subtitle.
class KpiCard extends StatelessWidget {
  /// Creates a [KpiCard].
  const KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.progress,
    super.key,
  });

  /// Upper label describing the metric.
  final String title;

  /// Primary formatted value displayed prominently.
  final String value;

  /// Supporting context label displayed at the bottom of the card.
  final String subtitle;

  /// Icon rendered inside the top-right tinted badge.
  final IconData icon;

  /// Primary accent color for the icon badge and progress bar.
  final Color accentColor;

  /// Optional normalized progress value (`0.0` to `1.0`).
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 17,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (progress != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(
                        begin: 0,
                        end: progress!.clamp(0.0, 1.0),
                      ),
                      builder: (context, animatedValue, _) {
                        return LinearProgressIndicator(
                          value: animatedValue,
                          minHeight: 5,
                          backgroundColor: isDark
                              ? AppColors.slate800
                              : AppColors.slate100,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(accentColor),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.slate400 : AppColors.slate500,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

