import 'package:flutter/material.dart';

import '../../../app/screens.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/widgets/aqua_symbol.dart';
import '../../../core/widgets/blur_circle.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onNavigate});

  final ValueChanged<AppScreen> onNavigate;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = true;
  bool passwordVisible = false;

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
                        hint: 'smeth@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _AuthPasswordField(
                        label: 'Password',
                        hint: '••••••••',
                        visible: passwordVisible,
                        onToggleVisibility: () =>
                            setState(() => passwordVisible = !passwordVisible),
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
                                  style: Theme.of(context).textTheme.bodyMedium
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
                        onPressed: () => widget.onNavigate(AppScreen.dashboard),
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
        ],
      ),
    );
  }
}

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key, required this.onNavigate});
  final ValueChanged<AppScreen> onNavigate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AquaColors.backgroundDark
          : AquaColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
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
                  const _AuthField(label: 'Full Name', hint: 'Alex Rivera'),
                  const SizedBox(height: 12),
                  const _AuthField(
                    label: 'Email',
                    hint: 'alex@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  const _AuthField(
                    label: 'Password',
                    hint: '••••••••',
                    obscure: true,
                  ),
                  const SizedBox(height: 16),
                  _PrimaryButton(
                    label: 'Sign Up',
                    onPressed: () => onNavigate(AppScreen.dashboard),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AquaColors.slate400
                              : AquaColors.slate500,
                        ),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () => onNavigate(AppScreen.login),
                              child: Text(
                                'Login',
                                style: Theme.of(context).textTheme.bodyMedium
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
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key, required this.onNavigate});

  final ValueChanged<AppScreen> onNavigate;

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
                onPressed: () => onNavigate(AppScreen.login),
                icon: const AquaSymbol('arrow_back'),
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AquaColors.slate400
                              : AquaColors.slate500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _AuthField(
                        label: 'Email Address',
                        hint: 'smeth@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                        
                      ),
                      const SizedBox(height: 24),
                      _PrimaryButton(
                        label: 'Send Reset Link',
                        onPressed: () => onNavigate(AppScreen.login),
                      ),
                    ],
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
            child: Image.asset(
              'assets/logo/logo.png',
              fit: BoxFit.contain,
            ),
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
    this.obscure = false,
  });

  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AquaColors.surfaceDark : Colors.white;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : AquaColors.slate200;

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
        SizedBox(
          height: 56,
          child: TextField(
            keyboardType: keyboardType,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: fill,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
  });

  final String label;
  final String hint;
  final bool visible;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AquaColors.surfaceDark : Colors.white;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : AquaColors.slate200;

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
        SizedBox(
          height: 56,
          child: TextField(
            obscureText: !visible,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: fill,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
              suffixIcon: IconButton(
                onPressed: onToggleVisibility,
                icon: AquaSymbol(
                  'visibility',
                  color: isDark ? AquaColors.slate300 : AquaColors.slate400,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
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
        child: Text(label),
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