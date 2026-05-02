/// Dashboard Principal — métricas, gráfico de utilización, próximas reservas.
library;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/neon_card.dart';
import '../../../core/widgets/neon_button.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/requests_provider.dart';
import '../reservation/reservation_screen.dart';
import '../requests/requests_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _DashboardBody(),
      const ReservationScreen(),
      const RequestsScreen(),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined),
              label: AppStrings.dashboard,
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 1 ? Icons.calendar_month : Icons.calendar_month_outlined),
              label: AppStrings.reserve,
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 2 ? Icons.mail : Icons.mail_outline),
              label: AppStrings.requests,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dash, _) {
        if (dash.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
        }
        final m = dash.metrics;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 20),
              // Title
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Text(AppStrings.todaySummary,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 16),

              // Metric cards row 1
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: Row(children: [
                  Expanded(child: _MetricCard(
                    icon: Icons.calendar_today, iconBg: AppColors.lightBlue,
                    value: '${m.reservationsToday}', label: AppStrings.reservationsToday,
                    badge: '+2', badgeColor: AppColors.primaryBlue,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(
                    icon: Icons.devices, iconBg: AppColors.lightBlue,
                    value: '${m.availableEquipment}', label: AppStrings.availableEquipment,
                    suffix: ' ${AppStrings.available}', topRight: AppStrings.totalEquipment,
                  )),
                ]),
              ),
              const SizedBox(height: 12),

              // Metric cards row 2
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: NeonCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.build_outlined, color: AppColors.primaryBlue, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Text('${m.inMaintenance}', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    Expanded(child: Text(AppStrings.inMaintenance, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary))),
                    Container(width: 1, height: 36, color: AppColors.divider),
                    const SizedBox(width: 16),
                    Text('${m.inUseNow}', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    Text(AppStrings.inUseNow, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 300),
                child: Row(children: [
                  Expanded(
                    child: NeonButton(
                      text: AppStrings.newReservation, height: 48, borderRadius: 24,
                      icon: Icons.add,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Consumer<RequestsProvider>(
                      builder: (_, rp, _) => InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {},
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                            color: AppColors.lightBlue.withValues(alpha: 0.3),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.mail_outline, size: 18, color: AppColors.primaryBlue),
                            const SizedBox(width: 8),
                            Text(AppStrings.viewRequests, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(10)),
                              child: Text('${rp.pendingCount}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 28),

              // Utilization chart
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 400),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(AppStrings.utilizationRate, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.2)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(16)),
                      child: Text(AppStrings.currentWeek, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  NeonCard(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(height: 180, child: _BarChart(data: m.weeklyUtilization)),
                  ),
                ]),
              ),
              const SizedBox(height: 28),

              // Upcoming reservations
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 500),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(AppStrings.upcomingReservations, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.2)),
                    Text(AppStrings.viewAll, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                  ]),
                  const SizedBox(height: 12),
                  ...dash.upcomingReservations.map((r) => FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: _ReservationTile(reservation: r),
                  )),
                ]),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.iconBg, required this.value, required this.label, this.badge, this.badgeColor, this.suffix, this.topRight});
  final IconData icon; final Color iconBg; final String value; final String label;
  final String? badge; final Color? badgeColor; final String? suffix; final String? topRight;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primaryBlue, size: 18),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(10)),
              child: Text(badge!, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          if (topRight != null)
            Text(topRight!, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary)),
        ]),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(value, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          if (suffix != null) Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 2),
            child: Text(suffix!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
          ),
        ]),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
      ]),
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
    _controller = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this)..forward();
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _BarChartPainter(data: widget.data, progress: _controller.value),
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

    // Y-axis labels
    final labelPaint = TextPainter(textDirection: TextDirection.ltr);
    for (var v in [0, 50, 100]) {
      labelPaint.text = TextSpan(text: '$v', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary));
      labelPaint.layout();
      final y = chartH - (v / 100 * chartH);
      labelPaint.paint(canvas, Offset(0, y - 6));
      // Grid line
      canvas.drawLine(Offset(28, y), Offset(size.width, y),
          Paint()..color = AppColors.divider.withValues(alpha: 0.3)..strokeWidth = 0.5);
    }

    for (int i = 0; i < data.length; i++) {
      final barH = (data[i] / maxVal) * chartH * progress;
      final x = 30 + i * (barW * 2);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, chartH - barH, barW, barH),
        const Radius.circular(4),
      );
      final gradient = LinearGradient(
        begin: Alignment.bottomCenter, end: Alignment.topCenter,
        colors: [AppColors.primaryBlue, AppColors.primaryBlue.withValues(alpha: 0.7)],
      );
      final paint = Paint()..shader = gradient.createShader(Rect.fromLTWH(x, chartH - barH, barW, barH));
      canvas.drawRRect(rect, paint);

      // Day label
      labelPaint.text = TextSpan(
        text: AppStrings.weekDays[i],
        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary),
      );
      labelPaint.layout();
      labelPaint.paint(canvas, Offset(x + barW / 2 - labelPaint.width / 2, chartH + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) => old.progress != progress;
}

class _ReservationTile extends StatelessWidget {
  const _ReservationTile({required this.reservation});
  final dynamic reservation;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        // Time badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
          ),
          child: Column(children: [
            Text('HOY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
            Text(reservation.startTime as String, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
          ]),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(reservation.location as String, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('${reservation.videobeamName} • ${reservation.department}',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        CircleAvatar(
          radius: 20, backgroundColor: AppColors.lightBlue,
          child: Text((reservation.userName as String).substring(0, 1),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
        ),
      ]),
    );
  }
}
