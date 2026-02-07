import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/screens.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/widgets/aqua_symbol.dart';
import '../../../core/widgets/blur_circle.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/auth_preferences_service.dart';
import '../../../core/services/user_database_service.dart';

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

  bool get _isFormValid {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
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
              content: const Text('Please verify your email first.'),
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
              title: const Text('Account Confirmed'),
              content: const Text(
                'Your account has been successfully verified. You are now logged in.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
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
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
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
                        _AuthBrandHeader(
                          title: 'Rayyan',
                          subtitle: 'Smart Hydroponics Management',
                          iconSize: 80,
                        ),
                        const SizedBox(height: 24),
                        _AuthField(
                          label: 'Email Address',
                          hint: 'Email Address',
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
                              return 'Please enter your email';
                            }
                            if (!_emailRegex.hasMatch(value)) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _AuthPasswordField(
                          label: 'Password',
                          hint: 'Password',
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
                              return 'Please enter your password';
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
                                  _SwitchPill(value: rememberMe),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Remember me',
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
                              onPressed: () =>
                                  widget.onNavigate(AppScreen.forgotPassword),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                foregroundColor: AquaColors.primary,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              child: const Text('Forgot Password?'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _PrimaryButton(
                          label: 'Sign In',
                          isLoading: isLoading,
                          onPressed: () => _handleLogin(),
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
                                const TextSpan(text: "Don't have an account? "),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: () =>
                                        widget.onNavigate(AppScreen.signup),
                                    child: Text(
                                      'Sign Up',
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

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key, required this.onNavigate});
  final ValueChanged<AppScreen> onNavigate;

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

  bool get _isFormValid {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _nameController.text.isNotEmpty;
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
            title: const Text('Verification Sent'),
            content: const Text(
              'We\'ve sent you a verification link to your email. Please check it.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  widget.onNavigate(AppScreen.login);
                },
                child: const Text('OK'),
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
            title: const Text('Error'),
            content: Text(e.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
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
                onPressed: () => widget.onNavigate(AppScreen.login),
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
                        _AuthBrandHeader(
                          title: 'Create Account',
                          subtitle: 'Join the future of automated farming',
                          iconSize: 64,
                          compact: true,
                        ),
                        const SizedBox(height: 24),
                        _AuthField(
                          label: 'Full Name',
                          hint: 'Alex Rivera',
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _AuthField(
                          label: 'Email',
                          hint: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!_emailRegex.hasMatch(value)) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _AuthPasswordField(
                          label: 'Password',
                          hint: 'Password',
                          visible: passwordVisible,
                          controller: _passwordController,
                          onToggleVisibility: () => setState(
                            () => passwordVisible = !passwordVisible,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _PrimaryButton(
                          label: 'Sign Up',
                          isLoading: isLoading,
                          onPressed: () => _handleSignup(),
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
                                const TextSpan(
                                  text: 'Already have an account? ',
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: () =>
                                        widget.onNavigate(AppScreen.login),
                                    child: Text(
                                      'Sign In',
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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, required this.onNavigate});

  final ValueChanged<AppScreen> onNavigate;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  bool isLoading = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _emailController.text.isNotEmpty;
  }

  Future<void> _handleReset() async {
    setState(() => _emailError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.sendPasswordResetEmail(_emailController.text.trim());

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset Link Sent'),
            content: const Text(
              'A password reset link has been sent to your email address.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onNavigate(AppScreen.login);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _emailError = e.message);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _formKey.currentState?.validate();
        });
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
                onPressed: () => widget.onNavigate(AppScreen.login),
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
                        Text(
                          'Reset Password',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter your email and we'll send you instructions to reset your password.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isDark
                                    ? AquaColors.slate400
                                    : AquaColors.slate500,
                              ),
                        ),
                        const SizedBox(height: 24),
                        _AuthField(
                          label: 'Email Address',
                          hint: 'smith@gmail.com',
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
                              return 'Please enter your email';
                            }
                            if (!_emailRegex.hasMatch(value)) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _PrimaryButton(
                          label: 'Send Reset Link',
                          isLoading: isLoading,
                          onPressed: () => _handleReset(),
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

// --- هنا تم التعديل لعرض اللوجو الخاص بك ---
class _AuthBrandHeader extends StatelessWidget {
  const _AuthBrandHeader({
    required this.title,
    required this.subtitle,
    required this.iconSize,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final double iconSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ضبط الألوان لتعطي تأثير التوهج النيوني
    final glowColor = AquaColors.primary.withOpacity(isDark ? 0.15 : 0.10);

    // جعل الحدود شفافة تماماً لإخفاء أطراف الدائرة
    final borderColor = Colors.transparent;
    // final fillColor = AquaColors.primary.withOpacity(isDark ? 0.15 : 0.08);

    return Column(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            // color: fillColor,
            // 1. زوايا دائرية أكبر لتطابق التصميم السابق
            borderRadius: BorderRadius.circular(24),
            // 2. حدود ناعمة
            border: Border.all(
              color: borderColor,
              width: 0,
              style: BorderStyle.none,
            ),
            boxShadow: compact
                ? null
                : [
                    // 3. توهج قوي وناعم (Neon Glow)
                    BoxShadow(
                      color: glowColor,
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 0),
                    ),
                  ],
          ),
          child: Center(
            child: Image.asset('assets/logo/logo.png', fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            // تأكدنا أن النص يظهر بوضوح في كلا الوضعين
            color: isDark ? Colors.white : AquaColors.slate900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark ? AquaColors.slate400 : AquaColors.slate500,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
        if (!compact) const SizedBox(height: 32),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.hint,
    this.keyboardType,
    this.controller,
    this.validator,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AquaColors.surfaceDark : Colors.white;
    final border = isDark
        ? Colors.white.withOpacity(0.10)
        : AquaColors.slate200;

    // Hint Color with opacity as requested
    final hintColor = isDark
        ? Colors.white.withOpacity(0.3)
        : Colors.black.withOpacity(0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          // Changed to TextFormField
          controller: controller,
          keyboardType: keyboardType,
          obscureText: false,
          validator: validator,
          style: TextStyle(
            color: isDark
                ? Colors.white
                : Colors.black, // Ensure input text is clear
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w400),
            filled: true,
            fillColor: fill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AquaColors.primary,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              // Professional error state
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthPasswordField extends StatelessWidget {
  const _AuthPasswordField({
    required this.label,
    required this.hint,
    required this.visible,
    required this.onToggleVisibility,
    this.controller,
    this.validator,
    this.onChanged,
  });

  final String label;
  final String hint;
  final bool visible;
  final VoidCallback onToggleVisibility;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AquaColors.surfaceDark : Colors.white;
    final border = isDark
        ? Colors.white.withOpacity(0.10)
        : AquaColors.slate200;

    final hintColor = isDark
        ? Colors.white.withOpacity(0.3)
        : Colors.black.withOpacity(0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !visible,
          validator: validator,
          onChanged: onChanged,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w400),
            filled: true,
            fillColor: fill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AquaColors.primary,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
            ),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: AquaSymbol(
                visible ? 'visibility' : 'visibility_off', // Toggling icon
                color: isDark ? AquaColors.slate300 : AquaColors.slate400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AquaColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AquaColors.primary.withValues(alpha: 0.30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(label),
      ),
    );
  }
}

class _SwitchPill extends StatelessWidget {
  const _SwitchPill({required this.value});
  final bool value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackOff = isDark ? AquaColors.slate700 : AquaColors.slate200;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: 40,
      height: 24,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: value ? AquaColors.primary : trackOff,
        borderRadius: BorderRadius.circular(999),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
