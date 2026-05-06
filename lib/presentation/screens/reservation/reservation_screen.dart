/// Pantalla de Reservación de Videobeam — selector, calendario, horarios.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/theme/app_colors.dart';

import '../../providers/reservation_provider.dart';

import 'components/videobeam_selector.dart';
import 'components/calendar_section.dart';
import 'components/time_slot_grid.dart';
import 'components/reservation_summary.dart';
import 'components/description_screen.dart';
import 'reservation_calendar_view.dart';

class ReservationScreen extends StatelessWidget {
  const ReservationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReservationProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Title & Calendar Button
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nueva Reservación',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ReservationCalendarView(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.primaryBlue,
                              size: 28,
                            ),
                            tooltip: 'Ver calendario',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sigue los siguientes pasos para realizar tu reservación',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Videobeam selector
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StepHeader(
                        step: 1,
                        title: 'Seleccionar VideoBeam',
                        icon: Icons.videocam_outlined,
                      ),
                      const SizedBox(height: 12),
                      VideobeamSelector(
                        videobeams: provider.videobeams,
                        selected: provider.selectedVideobeam,
                        onSelect: (v) => provider.selectVideobeam(v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Calendar
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StepHeader(
                        step: 2,
                        title: 'Seleccionar la fecha',
                        icon: Icons.calendar_today_outlined,
                      ),
                      const SizedBox(height: 12),
                      CalendarSection(
                        selectedDate: provider.selectedDate,
                        onDateSelected: (d) => provider.selectDate(d),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Time picker section
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StepHeader(
                        step: 3,
                        title: 'Seleccionar el horario',
                        icon: Icons.access_time_filled,
                      ),
                      const SizedBox(height: 16),
                      TimePickerSection(
                        startTime: provider.startTime,
                        endTime: provider.endTime,
                        onStartTimeSelected: (t) => provider.setStartTime(t),
                        onEndTimeSelected: (t) => provider.setEndTime(t),
                        selectedDate: provider.selectedDate,
                        videobeamId: provider.selectedVideobeam?.id,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Description field
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 350),
                  child: DescriptionScreen(
                    notes: provider.notes,
                    onChanged: (val) => provider.setNotes(val),
                  ),
                ),

                const SizedBox(height: 24),

                // Summary + confirm
                if (provider.selectedVideobeam != null &&
                    provider.startTime != null &&
                    provider.endTime != null)
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: ReservationSummary(provider: provider),
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.step,
    required this.title,
    required this.icon,
  });

  final int step;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.12),
            AppColors.primaryBlue.withValues(alpha: 0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$step',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            icon,
            size: 20,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
