import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Displays a friendly empty-state card when the user has no habits or when a category filter matches none.
class EmptyHabitsCard extends StatelessWidget {
  /// Creates an [EmptyHabitsCard].
  const EmptyHabitsCard({
    required this.isFilteredEmpty,
    required this.onPrimaryAction,
    super.key,
  });

  /// Whether the empty state is caused by an active category filter (`true`) or an empty workspace (`false`).
  final bool isFilteredEmpty;

  /// Callback invoked when the primary action button is pressed.
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.indigo500.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFilteredEmpty
                    ? Icons.filter_alt_off_rounded
                    : Icons.auto_awesome_rounded,
                color: AppColors.indigo500,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFilteredEmpty
                  ? 'No hay hábitos en esta categoría'
                  : 'Comienza tu primer hábito hoy',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFilteredEmpty
                  ? 'Prueba seleccionando otra categoría o muestra todos tus hábitos.'
                  : 'Crea hábitos personalizados, registra tu avance diario y construye rachas duraderas.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.slate500,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onPrimaryAction,
              icon: Icon(
                isFilteredEmpty ? Icons.clear_all_rounded : Icons.add_rounded,
              ),
              label: Text(
                isFilteredEmpty
                    ? 'Ver todas las categorías'
                    : 'Crear mi primer hábito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

