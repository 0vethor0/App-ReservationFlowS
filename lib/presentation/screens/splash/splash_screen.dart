/// Splash Screen con logo animado, glow neon y progress indicator.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..forward();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            const Spacer(flex: 3),
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(
                              alpha: _glowAnimation.value,
                            ),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icon/icon.png',
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppStrings.appName,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.appTagline,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 4,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: _progressController.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.splashLoading,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
