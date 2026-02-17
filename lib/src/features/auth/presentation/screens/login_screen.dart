import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/screens.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../core/theme/aqua_colors.dart';
import '../../../../core/widgets/blur_circle.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/auth_preferences_service.dart';
import '../../../../core/services/user_database_service.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/switch_pill.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, required this.onNavigate});

  final ValueChanged<AppScreen> onNavigate;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  bool rememberMe = false;
  bool passwordVisible = false;
  bool isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final prefsService = ref.read(authPreferencesServiceProvider);

      final user = await authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!user.emailVerified) {
        await authService.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.verifyEmailFirst),
              backgroundColor: AquaColors.critical,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // Check if user exists in DB and save if needed (first login after verification)
      final userDbService = ref.read(userDatabaseServiceProvider);
      final userExists = await userDbService.userExists(user.uid);

      if (!userExists) {
        await userDbService.saveUser(user);

        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.accountConfirmed),
              content: const Text(
                'Your account has been successfully verified. You are now logged in.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            ),
          );
        }
      }

      await prefsService.setRememberMe(rememberMe);

      if (mounted) {
        widget.onNavigate(AppScreen.dashboard);
      }
    } on AuthException catch (e) {
      if (mounted) {
        switch (e.code) {
          case 'wrong-password':
            setState(() => _passwordError = e.message);
            break;
          case 'user-not-found':
          case 'invalid-email':
            setState(() => _emailError = e.message);
            break;
          default:
            _showErrorDialog(e.message);
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _formKey.currentState?.validate();
        });
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AquaColors.backgroundDark
          : AquaColors.backgroundLight,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: BlurCircle(
              diameter: 256,
              color: AquaColors.primary,
              opacity: 0.10,
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: BlurCircle(
              diameter: 256,
              color: AquaColors.primary,
              opacity: 0.10,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 48,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        AuthBrandHeader(
                          title: AppLocalizations.of(context)!.rayyanTitle,
                          subtitle: AppLocalizations.of(
                            context,
                          )!.rayyanSubtitle,
                          iconSize: 80,
                        ),
                        const SizedBox(height: 24),
                        AuthField(
                          label: AppLocalizations.of(context)!.emailAddress,
                          hint: AppLocalizations.of(context)!.emailAddress,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          onChanged: (_) {
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                          validator: (value) {
                            if (_emailError != null) return _emailError;
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.pleaseEnterEmail;
                            }
                            if (!_emailRegex.hasMatch(value)) {
                              return AppLocalizations.of(
                                context,
                              )!.invalidEmailFormat;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthPasswordField(
                          label: AppLocalizations.of(context)!.password,
                          hint: AppLocalizations.of(context)!.password,
                          visible: passwordVisible,
                          controller: _passwordController,
                          onToggleVisibility: () => setState(
                            () => passwordVisible = !passwordVisible,
                          ),
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                          validator: (value) {
                            if (_passwordError != null) return _passwordError;
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.pleaseEnterPassword;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () =>
                                  setState(() => rememberMe = !rememberMe),
                              borderRadius: BorderRadius.circular(999),
                              child: Row(
                                children: [
                                  SwitchPill(value: rememberMe),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppLocalizations.of(context)!.rememberMe,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AquaColors.slate300
                                              : AquaColors.slate600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _navigateToForgotPassword,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                foregroundColor: AquaColors.primary,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.forgotPassword,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AuthButton(
                          label: AppLocalizations.of(context)!.signIn,
                          isLoading: isLoading,
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: isDark
                                        ? AquaColors.slate400
                                        : AquaColors.slate500,
                                  ),
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(
                                    context,
                                  )!.dontHaveAccount,
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: _navigateToSignup,
                                    child: Text(
                                      AppLocalizations.of(context)!.signUp,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AquaColors.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
