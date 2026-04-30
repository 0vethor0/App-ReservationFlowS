/// Splash Screen con logo animado, glow neon y progress indicator.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../login/login_screen.dart';

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
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, sec, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
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
                            color: AppColors.primaryBlue.withValues(alpha: _glowAnimation.value),
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
                      child: const Center(child: _BeamFlowLogo(size: 60)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppStrings.appName,
              style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.appTagline,
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary),
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
                      child: Stack(children: [
                        Container(decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(4))),
                        FractionallySizedBox(
                          widthFactor: _progressController.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 1)],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.splashLoading,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textTertiary, letterSpacing: 2),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _BeamFlowLogo extends StatelessWidget {
  const _BeamFlowLogo({this.size = 40});
  final double size;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _BeamFlowLogoPainter());
  }
}

class _BeamFlowLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final cy = size.height / 2;
    final l = size.width * 0.15;
    final r = size.width * 0.85;
    final a = size.width * 0.2;

    canvas.drawLine(Offset(l, size.height * 0.2), Offset(l, size.height * 0.8), paint);
    canvas.drawPath(Path()..moveTo(l, size.height * 0.2)..quadraticBezierTo(size.width * 0.55, size.height * 0.2, size.width * 0.55, cy * 0.85), paint);
    canvas.drawPath(Path()..moveTo(l, size.height * 0.8)..quadraticBezierTo(size.width * 0.55, size.height * 0.8, size.width * 0.55, cy * 1.15), paint);
    canvas.drawLine(Offset(size.width * 0.55, cy), Offset(r, cy), paint);
    canvas.drawLine(Offset(r - a * 0.6, cy - a * 0.5), Offset(r, cy), paint);
    canvas.drawLine(Offset(r - a * 0.6, cy + a * 0.5), Offset(r, cy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
