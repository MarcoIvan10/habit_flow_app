import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/enums/auth_form_mode.dart';
import '../../domain/states/auth_submission_state.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_feedback_banner.dart';
import '../widgets/auth_mode_segmented_toggle.dart';
import '../widgets/supabase_mode_banner.dart';

/// Top-level authentication screen providing login and account registration forms.
class AuthScreen extends ConsumerStatefulWidget {
  /// Creates an [AuthScreen].
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
    if (_mode == nextMode) {
      return;
    }
    setState(() => _mode = nextMode);
    _formKey.currentState?.reset();
    ref.read(authSubmissionProvider.notifier).resetState();
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await ref.read(authSubmissionProvider.notifier).submit(
          mode: _mode,
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  ({bool isSubmitting, String? feedbackBanner, bool isErrorBanner})
      _resolveSubmissionViewState(AuthSubmissionState submissionState) {
    return switch (submissionState) {
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
  }

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(authSubmissionProvider);
    final isSupabaseConfigured = ref.watch(isSupabaseInitializedProvider);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final viewState = _resolveSubmissionViewState(submissionState);

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
                  const AuthBrandHeader(),
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
                            AuthModeSegmentedToggle(
                              currentMode: _mode,
                              enabled: !viewState.isSubmitting,
                              onChanged: _switchMode,
                            ),
                            const SizedBox(height: 24),
                            if (viewState.feedbackBanner != null) ...[
                              AuthFeedbackBanner(
                                message: viewState.feedbackBanner!,
                                isError: viewState.isErrorBanner,
                              ),
                              const SizedBox(height: 16),
                            ],
                            TextFormField(
                              controller: _emailController,
                              enabled: !viewState.isSubmitting,
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
                              enabled: !viewState.isSubmitting,
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
                              onPressed:
                                  viewState.isSubmitting ? null : _onSubmit,
                              child: viewState.isSubmitting
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
