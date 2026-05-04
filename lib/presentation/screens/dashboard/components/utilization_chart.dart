/// Gráfico de utilización semanal.
library;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/neon_card.dart';

class UtilizationChart extends StatelessWidget {
  const UtilizationChart({
    super.key,
    required this.data,
  });

  final List<double> data;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.utilizationRate,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  AppStrings.currentWeek,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          NeonCard(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 180,
              child: _BarChart(data: data),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatefulWidget {
  const _BarChart({required this.data});
  final List<double> data;

  @override
  State<_BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<_BarChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _BarChartPainter(
            data: widget.data,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.data, required this.progress});
  final List<double> data;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.reduce(math.max);
    final barW = size.width / (data.length * 2 + 1);
    final chartH = size.height - 30;

    final labelPaint = TextPainter(textDirection: TextDirection.ltr);
    for (var v in [0, 50, 100]) {
      labelPaint.text = TextSpan(
        text: '$v',
        style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary),
      );
      labelPaint.layout();
      final y = chartH - (v / 100 * chartH);
      labelPaint.paint(canvas, Offset(0, y - 6));
      canvas.drawLine(
        Offset(28, y),
        Offset(size.width, y),
        Paint()
          ..color = AppColors.divider.withValues(alpha: 0.3)
          ..strokeWidth = 0.5,
      );
    }

    for (int i = 0; i < data.length; i++) {
      final barH = (data[i] / maxVal) * chartH * progress;
      final x = 30 + i * (barW * 2);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, chartH - barH, barW, barH),
        const Radius.circular(4),
      );
      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          AppColors.primaryBlue,
          AppColors.primaryBlue.withValues(alpha: 0.7),
        ],
      );
      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(x, chartH - barH, barW, barH),
        );
      canvas.drawRRect(rect, paint);

      labelPaint.text = TextSpan(
        text: AppStrings.weekDays[i],
        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary),
      );
      labelPaint.layout();
      labelPaint.paint(
        canvas,
        Offset(x + barW / 2 - labelPaint.width / 2, chartH + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) => old.progress != progress;
}