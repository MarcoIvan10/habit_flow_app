import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/dashboard_models.dart';

/// Cuadrícula 2x2 de tarjetas KPI de resumen (Sección 5.2 de la especificación).
class KpiGridWidget extends StatelessWidget {
  const KpiGridWidget({
    required this.summary,
    super.key,
  });

  final DashboardKpiSummary summary;

  @override
  Widget build(BuildContext context) {
    final todayPct = (summary.todayCompletionRate * 100).round();
    final weekPct = (summary.weekCompletionRate * 100).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 680;
        final crossAxisCount = isWide ? 4 : 2;
        final childAspectRatio = isWide ? 1.55 : 1.32;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            _KpiCard(
              title: 'Hábitos Activos',
              value: '${summary.activeHabitsCount}',
              subtitle:
                  'En ${summary.uniqueCategoriesCount} ${summary.uniqueCategoriesCount == 1 ? 'categoría' : 'categorías'}',
              icon: Icons.layers_rounded,
              accentColor: AppColors.indigo500,
            ),
            _KpiCard(
              title: 'Cumplimiento Hoy',
              value: '$todayPct%',
              subtitle:
                  '${summary.todayCompletedCount} de ${summary.activeHabitsCount} completados',
              icon: Icons.check_circle_outline_rounded,
              accentColor: todayPct == 100 && summary.activeHabitsCount > 0
                  ? AppColors.emerald500
                  : AppColors.indigo500,
              progress: summary.todayCompletionRate,
            ),
            _KpiCard(
              title: 'Mejor Racha Activa',
              value: '${summary.topStreakDays} d',
              subtitle: summary.topStreakHabitName,
              icon: Icons.local_fire_department_rounded,
              accentColor: AppColors.amber500,
            ),
            _KpiCard(
              title: 'Total en la Semana',
              value: '${summary.weekCompletedCount}/${summary.weekTargetCount}',
              subtitle: '$weekPct% de efectividad semanal',
              icon: Icons.insights_rounded,
              accentColor: AppColors.emerald500,
              progress: summary.weekCompletionRate,
            ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.progress,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
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

