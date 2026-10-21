import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/dashboard_kpi_summary.dart';
import 'kpi_card.dart';

/// Responsive grid displaying the four summary [KpiCard] items at the top of the dashboard.
class KpiGridWidget extends StatelessWidget {
  /// Creates a [KpiGridWidget].
  const KpiGridWidget({
    required this.summary,
    super.key,
  });

  /// Aggregated KPI metrics to render.
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
            KpiCard(
              title: 'Hábitos Activos',
              value: '${summary.activeHabitsCount}',
              subtitle:
                  'En ${summary.uniqueCategoriesCount} ${summary.uniqueCategoriesCount == 1 ? 'categoría' : 'categorías'}',
              icon: Icons.layers_rounded,
              accentColor: AppColors.indigo500,
            ),
            KpiCard(
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
            KpiCard(
              title: 'Mejor Racha Activa',
              value: '${summary.topStreakDays} d',
              subtitle: summary.topStreakHabitName,
              icon: Icons.local_fire_department_rounded,
              accentColor: AppColors.amber500,
            ),
            KpiCard(
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
