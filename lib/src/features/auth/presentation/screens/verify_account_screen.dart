import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../../core/theme/rayyan_colors.dart';
import '../../../../core/widgets/rayyan_symbol.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/auth_button.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/user_database_service.dart';

class VerifyAccountScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyAccountScreen({
    super.key, 
    required this.email,
  });

  @override
  ConsumerState<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends ConsumerState<VerifyAccountScreen> {
  String _otp = '';
  bool _isLoading = false;
  Timer? _timer;
  int _secondsRemaining = 300;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 300);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining / 60).floor().toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _verifyOtp() async {
    if (_otp.length < 6) return;
    
    setState(() => _isLoading = true);
    
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('otps')
          .doc(widget.email)
          .get();
          
      if (!docSnapshot.exists) {
        _showErrorDialog('Invalid or expired OTP code.');
        setState(() => _isLoading = false);
        return;
      }
      
      final data = docSnapshot.data()!;
      final storedOtp = data['otp'] as String?;
      final expiresAt = data['expiresAt'] as Timestamp?;
      
      if (storedOtp != _otp) {
        _showErrorDialog('Invalid OTP code. Please check and try again.');
        setState(() => _isLoading = false);
        return;
      }
      
      if (expiresAt != null && expiresAt.toDate().isBefore(DateTime.now())) {
        _showErrorDialog('This OTP code has expired. Please request a new one.');
        setState(() => _isLoading = false);
        return;
      }
      
      // Delete the document after successful verification
      await FirebaseFirestore.instance
          .collection('otps')
          .doc(widget.email)
          .delete();
          
      try {
        final authService = ref.read(firebaseAuthServiceProvider);
        
        final user = authService.currentUser;
        if (user != null) {
          final userDbService = ref.read(userDatabaseServiceProvider);
          await userDbService.saveUser(user);
        }
      } catch (e) {
        debugPrint('Failed to save verified user: $e');
      }
          
      if (!mounted) return;
      
      // Optionally show success dialog and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account verified successfully!')),
      );
      
      Navigator.of(context).pop();
      
    } catch (e) {
      _showErrorDialog('Error verifying code: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      // using default 'ar' as requested
      await authService.sendEmailOtp(widget.email, lang: 'ar');
      
      _startTimer();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code resent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to resend code: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.error ?? 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? RayyanColors.backgroundDark : RayyanColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Rayyan Logo
                      Center(
                        child: Image.asset(
                          'assets/logo/logo.png',
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.water_drop, size: 80, color: RayyanColors.primary);
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Title
                      Text(
                        'Verify Your Account',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : RayyanColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      Text(
                        'Enter the 6-digit code sent to your email',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? RayyanColors.slate400 : RayyanColors.slate500,
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // OTP Input
                      OtpInputField(
                        length: 6,
                        onChanged: (val) {
                          setState(() {
                            _otp = val;
                          });
                        },
                        onCompleted: (val) {
                          _verifyOtp();
                        },
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Verify Button
                      AuthButton(
                        label: 'VERIFY',
                        isLoading: _isLoading,
                        onPressed: _otp.length == 6 ? _verifyOtp : () {},
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Timer text
                      Center(
                        child: Text(
                          'Code expires in $_formattedTime',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? RayyanColors.slate400 : RayyanColors.slate500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Resend Code
                      Center(
                        child: TextButton(
                          onPressed: _isLoading ? null : _resendCode,
                          child: Text(
                            'Resend Code',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark ? RayyanColors.slate400 : RayyanColors.slate500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const RayyanSymbol('arrow_back_ios_new'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
