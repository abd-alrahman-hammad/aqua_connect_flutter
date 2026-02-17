import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../core/theme/aqua_colors.dart';
import '../../../../core/widgets/aqua_symbol.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool passwordVisible = false;
  bool isLoading = false;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _nameController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final authService = ref.read(firebaseAuthServiceProvider);

      final user = await authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      await authService.sendEmailVerification(user);
      await authService.updateDisplayName(_nameController.text.trim());

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.verificationSent),
            content: Text(
              AppLocalizations.of(context)!.verificationSentMessage,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                  Navigator.pop(context); // Go back to login
                },
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.error),
            content: Text(e.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AquaColors.backgroundDark
          : AquaColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const AquaSymbol('arrow_back_ios_new'),
              ),
            ),
            Center(
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
                        AuthBrandHeader(
                          title: AppLocalizations.of(context)!.createAccount,
                          subtitle: AppLocalizations.of(context)!.joinFuture,
                          iconSize: 64,
                          compact: true,
                        ),
                        const SizedBox(height: 24),
                        AuthField(
                          label: AppLocalizations.of(context)!.fullName,
                          hint: AppLocalizations.of(context)!.fullNameHint,
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.pleaseEnterFullName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AuthField(
                          label: AppLocalizations.of(context)!.emailAddress,
                          hint: AppLocalizations.of(context)!.emailAddress,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          validator: (value) {
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
                        const SizedBox(height: 12),
                        AuthPasswordField(
                          label: AppLocalizations.of(context)!.password,
                          hint: AppLocalizations.of(context)!.password,
                          visible: passwordVisible,
                          controller: _passwordController,
                          onToggleVisibility: () => setState(
                            () => passwordVisible = !passwordVisible,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.pleaseEnterAPassword;
                            }
                            if (value.length < 8) {
                              return AppLocalizations.of(
                                context,
                              )!.passwordLengthError;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthButton(
                          label: AppLocalizations.of(context)!.signUp,
                          isLoading: isLoading,
                          onPressed: _handleSignup,
                        ),
                        const SizedBox(height: 12),
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
                                  )!.alreadyHaveAccount,
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Text(
                                      AppLocalizations.of(context)!.signIn,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
