/// Componente de selector de horarios con validación de disponibilidad.
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';

class TimePickerSection extends StatefulWidget {
  const TimePickerSection({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeSelected,
    required this.onEndTimeSelected,
    required this.selectedDate,
    required this.videobeamId,
  });

  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final ValueChanged<TimeOfDay> onStartTimeSelected;
  final ValueChanged<TimeOfDay> onEndTimeSelected;
  final DateTime selectedDate;
  final String? videobeamId;

  @override
  State<TimePickerSection> createState() => _TimePickerSectionState();
}

class _TimePickerSectionState extends State<TimePickerSection> {
  bool _isCheckingAvailability = false;
  String? _availabilityError;

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final initialTime = isStartTime 
        ? (widget.startTime ?? TimeOfDay.now()) 
        : (widget.endTime ?? TimeOfDay.now());

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      if (isStartTime) {
        widget.onStartTimeSelected(pickedTime);
      } else {
        widget.onEndTimeSelected(pickedTime);
      }

      if (mounted) {
        await _validateTimeSelection();
      }
    }
  }

  Future<void> _validateTimeSelection() async {
    setState(() {
      _availabilityError = null;
    });

    if (widget.startTime != null && widget.endTime != null) {
      final startMinutes = widget.startTime!.hour * 60 + widget.startTime!.minute;
      final endMinutes = widget.endTime!.hour * 60 + widget.endTime!.minute;

      if (startMinutes == endMinutes) {
        setState(() {
          _availabilityError = 'La hora de inicio no puede ser igual a la hora de fin';
        });
        return;
      }

      if (endMinutes < startMinutes) {
        setState(() {
          _availabilityError = 'La hora de fin no puede ser anterior a la hora de inicio';
        });
        return;
      }

      await _checkAvailability();
    }
  }

  Future<void> _checkAvailability() async {
    if (widget.videobeamId == null) return;
    if (widget.startTime == null || widget.endTime == null) return;

    final startMinutes = widget.startTime!.hour * 60 + widget.startTime!.minute;
    final endMinutes = widget.endTime!.hour * 60 + widget.endTime!.minute;

    setState(() {
      _isCheckingAvailability = true;
      _availabilityError = null;
    });

    try {
      final supabase = Supabase.instance.client;

      final dateStr = '${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}';

      final response = await supabase
          .from('reservas')
          .select('*')
          .eq('id_producto', widget.videobeamId!)
          .eq('estado_reserva', 'aprobada')
          .like('hora_inicio', '$dateStr%');

      if (response.isNotEmpty) {
        for (final reservation in response) {
          final existingStart = DateTime.parse(reservation['hora_inicio'] as String);
          final existingEnd = DateTime.parse(reservation['hora_fin'] as String);

          final existingStartMinutes = existingStart.hour * 60 + existingStart.minute;
          final existingEndMinutes = existingEnd.hour * 60 + existingEnd.minute;

          if ((startMinutes >= existingStartMinutes && startMinutes < existingEndMinutes) ||
              (endMinutes > existingStartMinutes && endMinutes <= existingEndMinutes) ||
              (startMinutes <= existingStartMinutes && endMinutes >= existingEndMinutes)) {
            final existingDate = existingStart.day;
            final existingMonth = existingStart.month;
            final existingYear = existingStart.year;

            if (existingDate == widget.selectedDate.day &&
                existingMonth == widget.selectedDate.month &&
                existingYear == widget.selectedDate.year) {
              final startFormatted = '${existingStart.hour.toString().padLeft(2, '0')}:${existingStart.minute.toString().padLeft(2, '0')}';
              final endFormatted = '${existingEnd.hour.toString().padLeft(2, '0')}:${existingEnd.minute.toString().padLeft(2, '0')}';

              setState(() {
                _availabilityError = 'No puedes elegir ese bloque de horas ($startFormatted - $endFormatted) en este día, ya que otro usuario ya tiene una reservación';
              });
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error verificando disponibilidad: $e');
    } finally {
      setState(() {
        _isCheckingAvailability = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _TimeInputButton(
                label: 'Hora de Inicio',
                time: widget.startTime,
                onTap: () => _selectTime(context, true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _TimeInputButton(
                label: 'Hora de Cierre',
                time: widget.endTime,
                onTap: () => _selectTime(context, false),
              ),
            ),
          ],
        ),
        if (_isCheckingAvailability) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Verificando disponibilidad...',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
        if (_availabilityError != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _availabilityError!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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