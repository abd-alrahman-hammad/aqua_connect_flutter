import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../app/screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onNavigate,
  });

  final void Function(AppScreen) onNavigate;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // إعداد الأنيميشن (مدة ثانية ونصف للظهور الناعم)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // تأثير الظهور (Fade In)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // تأثير التكبير البسيط (Scale Up)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // بدء الأنيميشن فوراً
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;

    final backgroundColor = isDark ? AquaColors.backgroundDark : AquaColors.backgroundLight;
    final textColor = isDark ? Colors.white : AquaColors.slate900;
    // جعلنا لون الشريط أفتح قليلاً ليتناسب مع التصميم الحديث
    final trackColor = isDark ? AquaColors.slate700.withOpacity(0.3) : AquaColors.slate200;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          _buildBackgroundBlobs(isDark),
          
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- القسم المتحرك (اللوجو والنصوص) ---
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          children: [
                            // اللوجو مع ظل خفيف ليعطيه عمقاً
                            _buildLogo(),
                            
                            const SizedBox(height: 32),

                            Text(
                              'Aqua Connect',
                              style: GoogleFonts.manrope( // غيرت الخط لـ Manrope ليتناسب مع باقي التطبيق
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -1.0,
                              ),
                            ),
                            
                            const SizedBox(height: 12),

                            Text(
                              'Smart Hydroponics Management',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AquaColors.slate500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // شريط التحميل (منفصل عن أنيميشن اللوجو)
                    _buildProgressBar(trackColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 160,
      height: 160,
      // إضافة ظل خفيف جداً خلف اللوجو لبروزه
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AquaColors.primary.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Image.asset(
        'assets/logo/logo.png',
        fit: BoxFit.contain,
        // هذا السطر مهم جداً لتجنب الوميض، فهو يخفي الصورة حتى يتم تحميلها بالكامل
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(Color trackColor) {
    return SizedBox(
      width: 180, // جعلناه أصغر قليلاً لأناقة أكثر
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 3),
        curve: Curves.easeInOutQuart, // حركة أنعم في البداية والنهاية
        onEnd: () => widget.onNavigate(AppScreen.login),
        builder: (context, value, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: trackColor,
              valueColor: const AlwaysStoppedAnimation<Color>(AquaColors.primary),
              minHeight: 4, // جعلناه أنحف
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundBlobs(bool isDark) {
    // تقليل الشفافية ليكون الخلفية هادئة أكثر
    final primaryBlobColor = AquaColors.primary.withOpacity(isDark ? 0.08 : 0.05);
    final aquaBlobColor = AquaColors.aqua.withOpacity(isDark ? 0.08 : 0.05);

    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -80,
          child: _buildBlob(primaryBlobColor, 350), // تكبير الحجم قليلاً
        ),
        Positioned(
          bottom: -100,
          right: -80,
          child: _buildBlob(aquaBlobColor, 350),
        ),
      ],
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), // زيادة التغبيش لنعومة أكثر
        child: Container(
          decoration: const BoxDecoration(shape: BoxShape.circle),
        ),
      ),
    );
  }
}