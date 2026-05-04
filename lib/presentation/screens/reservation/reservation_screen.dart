/// Pantalla de Reservación de Videobeam — selector, calendario, horarios.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.reserve,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
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
                ),

                const SizedBox(height: 20),

                // Videobeam selector
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 100),
                  child: VideobeamSelector(
                    videobeams: provider.videobeams,
                    selected: provider.selectedVideobeam,
                    onSelect: (v) => provider.selectVideobeam(v),
                  ),
                ),

                const SizedBox(height: 24),

                // Calendar
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: CalendarSection(
                    selectedDate: provider.selectedDate,
                    onDateSelected: (d) => provider.selectDate(d),
                  ),
                ),

                const SizedBox(height: 24),

                // Time picker section
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 300),
                  child: TimePickerSection(
                    startTime: provider.startTime,
                    endTime: provider.endTime,
                    onStartTimeSelected: (t) => provider.setStartTime(t),
                    onEndTimeSelected: (t) => provider.setEndTime(t),
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
