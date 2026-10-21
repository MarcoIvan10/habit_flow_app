import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/app_user.dart';

/// Top application bar for the habits dashboard displaying the brand badge,
/// active user email, theme mode toggle button, and sign-out action.
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a [DashboardAppBar].
  const DashboardAppBar({
    required this.user,
    required this.isDark,
    required this.onToggleTheme,
    required this.onSignOut,
    super.key,
  });

  /// Currently authenticated user.
  final AppUser user;

  /// Whether dark mode is currently active.
  final bool isDark;

  /// Callback invoked when the theme toggle button is pressed.
  final VoidCallback onToggleTheme;

  /// Callback invoked when the sign-out button is pressed.
  final VoidCallback onSignOut;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.indigo500, AppColors.emerald500],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(AppConstants.appName),
                Text(
                  user.isDemo
                      ? 'Modo Demo • ${user.displayName}'
                      : user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.slate400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
          onPressed: onToggleTheme,
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          ),
        ),
        IconButton(
          tooltip: 'Cerrar sesión',
          onPressed: onSignOut,
          icon: const Icon(Icons.logout_rounded),
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}

