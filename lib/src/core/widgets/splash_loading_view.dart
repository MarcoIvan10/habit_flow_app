import 'package:flutter/material.dart';

/// Displays a centered loading indicator while initial authentication state resolves.
class SplashLoadingView extends StatelessWidget {
  /// Creates a [SplashLoadingView].
  const SplashLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

