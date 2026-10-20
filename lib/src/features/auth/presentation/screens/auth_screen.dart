import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/models/auth_ui_state.dart';
import '../providers/auth_providers.dart';
import '../widgets/supabase_mode_banner.dart';

/// Pantalla de Autenticación (Login / Registro) con diseño SaaS moderno y soporte Dark Mode.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthFormMode _mode = AuthFormMode.signIn;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchMode(AuthFormMode nextMode) {
    if (_mode == nextMode) return;
    setState(() => _mode = nextMode);
    _formKey.currentState?.reset();
    ref.read(authSubmissionProvider.notifier).resetState();
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(authSubmissionProvider.notifier).submit(
          mode: _mode,
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(authSubmissionProvider);
    final isSupabaseConfigured = ref.watch(isSupabaseInitializedProvider);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // Pattern matching exhaustivo sobre el estado sellado AuthSubmissionState
    final (:bool isSubmitting, :String? feedbackBanner, :bool isErrorBanner) =
        switch (submissionState) {
      AuthSubmissionIdle() => (
          isSubmitting: false,
          feedbackBanner: null,
          isErrorBanner: false,
        ),
      AuthSubmissionSubmitting() => (
          isSubmitting: true,
          feedbackBanner: null,
          isErrorBanner: false,
        ),
      AuthSubmissionSuccess(:final infoMessage) => (
          isSubmitting: false,
          feedbackBanner: infoMessage,
          isErrorBanner: false,
        ),
      AuthSubmissionFailure(:final errorMessage) => (
          isSubmitting: false,
          feedbackBanner: errorMessage,
          isErrorBanner: true,
        ),
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme(brightness);
            },
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _AuthBrandHeader(),
                  const SizedBox(height: 24),
                  SupabaseModeBanner(
                    isSupabaseConfigured: isSupabaseConfigured,
                  ),
                  if (!isSupabaseConfigured) const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _AuthModeSegmentedToggle(
                              currentMode: _mode,
                              enabled: !isSubmitting,
                              onChanged: _switchMode,
                            ),
                            const SizedBox(height: 24),
                            if (feedbackBanner != null) ...[
                              _FeedbackAlertBanner(
                                message: feedbackBanner,
                                isError: isErrorBanner,
                              ),
                              const SizedBox(height: 16),
                            ],
                            TextFormField(
                              controller: _emailController,
                              enabled: !isSubmitting,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              autofillHints: const [AutofillHints.email],
                              validator: Validators.validateEmail,
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                hintText: 'tu@correo.com',
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              enabled: !isSubmitting,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: _mode == AuthFormMode.signIn
                                  ? const [AutofillHints.password]
                                  : const [AutofillHints.newPassword],
                              onFieldSubmitted: (_) => _onSubmit(),
                              validator: (val) => Validators.validatePassword(
                                val,
                                isSignUp: _mode == AuthFormMode.signUp,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                hintText: 'Mínimo 8 caracteres',
                                prefixIcon:
                                    const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Mostrar contraseña'
                                      : 'Ocultar contraseña',
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: isSubmitting ? null : _onSubmit,
                              child: isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _mode == AuthFormMode.signIn
                                          ? 'Iniciar Sesión'
                                          : 'Crear Cuenta',
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _AuthBrandHeader extends StatelessWidget {
  const _AuthBrandHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.indigo500, AppColors.emerald500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.indigo500.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppConstants.appName,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppConstants.appTagline,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.slate500,
          ),
        ),
      ],
    );
  }
}

class _AuthModeSegmentedToggle extends StatelessWidget {
  const _AuthModeSegmentedToggle({
    required this.currentMode,
    required this.enabled,
    required this.onChanged,
  });

  final AuthFormMode currentMode;
  final bool enabled;
  final ValueChanged<AuthFormMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AuthFormMode>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment<AuthFormMode>(
          value: AuthFormMode.signIn,
          label: Text('Iniciar Sesión'),
          icon: Icon(Icons.login_rounded, size: 18),
        ),
        ButtonSegment<AuthFormMode>(
          value: AuthFormMode.signUp,
          label: Text('Registrarse'),
          icon: Icon(Icons.person_add_alt_1_rounded, size: 18),
        ),
      ],
      selected: {currentMode},
      onSelectionChanged: enabled ? (set) => onChanged(set.first) : null,
    );
  }
}

class _FeedbackAlertBanner extends StatelessWidget {
  const _FeedbackAlertBanner({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final accentColor = isError ? AppColors.rose500 : AppColors.emerald500;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: accentColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

