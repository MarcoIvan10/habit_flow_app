import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Renders a compact color indicator dot paired with a text label for chart legends.
class ChartLegendDot extends StatelessWidget {
  /// Creates a [ChartLegendDot].
  const ChartLegendDot({
    required this.color,
    required this.label,
    super.key,
  });

  /// Color of the legend swatch.
  final Color color;

  /// Descriptive text label next to the swatch.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.slate500,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

