import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/widgets/splash_loading_view.dart';
import 'features/auth/domain/states/auth_session_state.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/habits/presentation/screens/dashboard_screen.dart';

/// Root widget for the HabitFlow application configuring themes, navigation bar styles, and reactive auth routing.
class HabitFlowApp extends ConsumerWidget {
  /// Creates a [HabitFlowApp] instance.
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authSession = ref.watch(authSessionProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final overlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor:
              isDark ? AppColors.slate950 : AppColors.slate50,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: switch (authSession) {
          AuthSessionLoading() => const SplashLoadingView(
              key: ValueKey('splash_loading'),
            ),
          AuthSessionAuthenticated(:final user) => DashboardScreen(
              key: ValueKey('dashboard_${user.id}'),
              user: user,
            ),
          AuthSessionUnauthenticated() => const AuthScreen(
              key: ValueKey('auth_screen'),
            ),
        },
      ),
    );
  }
}
