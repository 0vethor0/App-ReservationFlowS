/// Componente de selector de horarios utilizando showTimePicker nativo.
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class TimePickerSection extends StatelessWidget {
  const TimePickerSection({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeSelected,
    required this.onEndTimeSelected,
  });

  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final ValueChanged<TimeOfDay> onStartTimeSelected;
  final ValueChanged<TimeOfDay> onEndTimeSelected;

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final initialTime = isStartTime 
        ? (startTime ?? TimeOfDay.now()) 
        : (endTime ?? TimeOfDay.now());

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: AppColors.textPrimary, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      if (isStartTime) {
        onStartTimeSelected(pickedTime);
      } else {
        onEndTimeSelected(pickedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona el Horario',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _TimeInputButton(
                label: 'Hora de Inicio',
                time: startTime,
                onTap: () => _selectTime(context, true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _TimeInputButton(
                label: 'Hora de Cierre',
                time: endTime,
                onTap: () => _selectTime(context, false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeInputButton extends StatelessWidget {
  const _TimeInputButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time?.format(context) ?? '--:--',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: time != null ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: time != null ? AppColors.primaryBlue : AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}