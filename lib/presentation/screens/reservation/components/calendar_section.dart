/// Componente de selección de fecha (Calendario).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/neon_card.dart';

class CalendarSection extends StatelessWidget {
  const CalendarSection({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.selectDate,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        NeonCard(
          padding: const EdgeInsets.all(8),
          glowOpacity: 0.05,
          child: TableCalendar(
            locale: 'es_ES',
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: selectedDate,
            currentDay: selectedDate,
            calendarFormat: CalendarFormat.week,
            availableCalendarFormats: const {CalendarFormat.week: 'Semana'},
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              titleTextStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              formatButtonVisible: false,
              leftChevronIcon: const Icon(
                Icons.chevron_left,
                color: AppColors.primaryBlue,
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right,
                color: AppColors.primaryBlue,
              ),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: GoogleFonts.inter(color: AppColors.textPrimary),
              weekendTextStyle: GoogleFonts.inter(
                color: AppColors.textSecondary,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) =>
                onDateSelected(selectedDay),
            selectedDayPredicate: (day) => isSameDay(selectedDate, day),
          ),
        ),
      ],
    );
  }
}
