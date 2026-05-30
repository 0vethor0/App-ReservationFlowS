/// Pantalla de Reservación de Videobeam — selector, calendario, horarios.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import 'package:beam_reserve/core/theme/app_colors.dart';
import 'package:beam_reserve/presentation/providers/reservation_provider.dart';
import 'package:beam_reserve/features/view_reservation_calendar/domain/repositories/view_reservation_calendar_repository.dart';
import 'package:beam_reserve/presentation/providers/reservation_calendar_provider.dart';
import 'package:beam_reserve/presentation/screens/view_reservation_calendar/view_reservation_calendar_screen.dart';

import 'components/videobeam_selector.dart';
import 'components/calendar_section.dart';
import 'components/time_slot_grid.dart';
import 'components/reservation_summary.dart';
import 'components/description_screen.dart';
import 'reservation_calendar_view.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  bool? _showCalendarChoice;

  @override
  Widget build(BuildContext context) {
    if (_showCalendarChoice == null) {
      // Step 1: Decision screen prompt
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Center(
              child: FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.15),
                        ),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        size: 64,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '¿Para continuar, desea inspeccionar primero las reservaciones actuales a la fecha hechas por otros usuarios?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Esto le permitirá ver los horarios ocupados y planificar mejor su reservación.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _showCalendarChoice = false;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Reservar',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showCalendarChoice = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Ver calendario',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_showCalendarChoice == true) {
      // Step 3: Inspeccionar calendario (split screen view)
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ViewReservationCalendarScreen(
              onGoToReserve: () {
                setState(() {
                  _showCalendarChoice = false;
                });
              },
            ),
          ),
        ),
      );
    }

    // Step 2: Traditional reservation steps
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ReservationProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Title & Buttons
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showCalendarChoice = true;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.info_outline_rounded,
                                    color: AppColors.primaryBlue,
                                    size: 26,
                                  ),
                                  tooltip: 'Inspeccionar calendario',
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChangeNotifierProvider(
                                          create: (ctx) =>
                                              ReservationCalendarProvider(
                                                ctx
                                                    .read<
                                                      ViewReservationCalendarRepository
                                                    >(),
                                              ),
                                          child:
                                              const ReservationCalendarView(),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.calendar_month_rounded,
                                    color: AppColors.primaryBlue,
                                    size: 26,
                                  ),
                                  tooltip: 'Ver calendario mensual',
                                ),
                              ],
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
                        const _StepHeader(
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
                        const _StepHeader(
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
                        const _StepHeader(
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
      ),
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
          Icon(icon, size: 20, color: AppColors.primaryBlue),
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
