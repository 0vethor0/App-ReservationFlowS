library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/reservation_provider.dart';
import '../../../../features/reservations/domain/entities/time_slot.dart';

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

  static const int _minHour = 7; // 7:00 AM VET
  static const int _maxHour = 17; // 5:00 PM VET

  @override
  void dispose() {
    super.dispose();
  }

  bool _isTimeBlocked(BuildContext context, int minutes) {
    final provider = context.read<ReservationProvider>();
    for (final slot in provider.bloquesOcupadosDelDia) {
      final startMin = slot.start.hour * 60 + slot.start.minute;
      final endMin = slot.end.hour * 60 + slot.end.minute;
      if (minutes >= startMin && minutes < endMin) {
        return true;
      }
    }
    return false;
  }

  bool _isRangeBlocked(BuildContext context, int startMinutes, int endMinutes) {
    final provider = context.read<ReservationProvider>();
    for (final slot in provider.bloquesOcupadosDelDia) {
      final startMin = slot.start.hour * 60 + slot.start.minute;
      final endMin = slot.end.hour * 60 + slot.end.minute;
      if ((startMinutes >= startMin && startMinutes < endMin) ||
          (endMinutes > startMin && endMinutes <= endMin) ||
          (startMinutes <= startMin && endMinutes >= endMin)) {
        return true;
      }
    }
    return false;
  }

  String _formatHour(int hour) {
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h:00 $period';
  }

  /// Despliega el BottomSheet con el selector de rodillo vertical personalizado de 12 horas.

  /// Despliega el BottomSheet con el selector de rodillo vertical personalizado de 12 horas.

  /// Despliega el BottomSheet con el selector de rodillo vertical personalizado de 12 horas.
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final initialTime = isStartTime
        ? (widget.startTime ?? const TimeOfDay(hour: 7, minute: 0))
        : (widget.endTime ?? const TimeOfDay(hour: 8, minute: 0));

    TimeOfDay pickedTime = initialTime;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _VerticalScrollTimePickerModal(
          initialTime: initialTime,
          onTimeChanged: (newTime) {
            pickedTime = newTime;
          },
        );
      },
    );

    // Al cerrar el modal, procesamos la hora seleccionada
    if (!context.mounted) return;
    final minutes = pickedTime.hour * 60 + pickedTime.minute;
    final minAllowed = _minHour * 60;
    final maxAllowed = _maxHour * 60;

    if (minutes < minAllowed || minutes > maxAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo se permiten reservaciones de 7:00 AM a 5:00 PM'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_isTimeBlocked(context, minutes)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta hora ya está reservada por otro usuario'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (isStartTime) {
      widget.onStartTimeSelected(pickedTime);
    } else {
      widget.onEndTimeSelected(pickedTime);
    }

    if (mounted) {
      await _validateTimeSelection();
    }
  }

  Future<void> _validateTimeSelection() async {
    setState(() {
      _availabilityError = null;
    });

    if (widget.startTime != null && widget.endTime != null) {
      final startMinutes =
          widget.startTime!.hour * 60 + widget.startTime!.minute;
      final endMinutes = widget.endTime!.hour * 60 + widget.endTime!.minute;

      if (startMinutes == endMinutes) {
        setState(() {
          _availabilityError =
              'La hora de inicio no puede ser igual a la hora de fin';
        });
        return;
      }

      if (endMinutes < startMinutes) {
        setState(() {
          _availabilityError =
              'La hora de fin no puede ser anterior a la hora de inicio';
        });
        return;
      }

      if (_isRangeBlocked(context, startMinutes, endMinutes)) {
        setState(() {
          _availabilityError =
              'No puedes elegir ese bloque de horas en este día, ya que otro usuario ya tiene una reservación';
        });
        return;
      }

      await _checkAvailability();
    }
  }

  Future<void> _checkAvailability() async {
    if (widget.videobeamId == null) return;
    if (widget.startTime == null || widget.endTime == null) return;

    setState(() {
      _isCheckingAvailability = true;
    });

    try {
      final supabase = Supabase.instance.client;

      final dateStr =
          '${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}';

      final response = await supabase
          .from('reservas')
          .select('hora_inicio, hora_fin')
          .eq('id_producto', widget.videobeamId!)
          .inFilter('estado_reserva', ['aprobada', 'en_curso'])
          .like('hora_inicio', '$dateStr%');

      if (response.isNotEmpty) {
        for (final reservation in response) {
          final existingStart = DateTime.parse(
            reservation['hora_inicio'] as String,
          );
          final existingEnd = DateTime.parse(reservation['hora_fin'] as String);

          final startMinutes =
              widget.startTime!.hour * 60 + widget.startTime!.minute;
          final endMinutes = widget.endTime!.hour * 60 + widget.endTime!.minute;
          final existingStartMinutes =
              existingStart.hour * 60 + existingStart.minute;
          final existingEndMinutes = existingEnd.hour * 60 + existingEnd.minute;

          if ((startMinutes >= existingStartMinutes &&
                  startMinutes < existingEndMinutes) ||
              (endMinutes > existingStartMinutes &&
                  endMinutes <= existingEndMinutes) ||
              (startMinutes <= existingStartMinutes &&
                  endMinutes >= existingEndMinutes)) {
            setState(() {
              _availabilityError =
                  'No puedes elegir ese bloque de horas en este día, ya que otro usuario ya tiene una reservación';
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('[TimeSlotGrid] Error checking availability: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingAvailability = false;
        });
      }
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
        const SizedBox(height: 16),
        _TimeRangeBar(
          blockedRanges: context
              .watch<ReservationProvider>()
              .bloquesOcupadosDelDia,
          startTime: widget.startTime,
          endTime: widget.endTime,
          minHour: _minHour,
          maxHour: _maxHour,
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            children: [
              const TextSpan(text: 'Horario permitido: '),
              TextSpan(
                text: '${_formatHour(_minHour)} - ${_formatHour(_maxHour)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
        if (context
            .watch<ReservationProvider>()
            .bloquesOcupadosDelDia
            .isNotEmpty) ...[
          const SizedBox(height: 4),
          ...List.generate(
            context.watch<ReservationProvider>().bloquesOcupadosDelDia.length,
            (i) {
              final r = context
                  .watch<ReservationProvider>()
                  .bloquesOcupadosDelDia[i];
              final sh = r.start.hour;
              final sm = r.start.minute;
              final eh = r.end.hour;
              final em = r.end.minute;
              return Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '• ${sh.toString().padLeft(2, '0')}:${sm.toString().padLeft(2, '0')} - ${eh.toString().padLeft(2, '0')}:${em.toString().padLeft(2, '0')} ${sh < 12 ? 'AM' : 'PM'} (reservado)',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.error.withValues(alpha: 0.8),
                  ),
                ),
              );
            },
          ),
        ],
        if (_isCheckingAvailability) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(
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
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
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

  String _formatTimeOfDay(TimeOfDay tod) {
    final period = tod.hour < 12 ? 'AM' : 'PM';
    final h = tod.hour == 0 ? 12 : (tod.hour > 12 ? tod.hour - 12 : tod.hour);
    final m = tod.minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

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
                  time != null ? _formatTimeOfDay(time!) : '--:--',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: time != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: time != null
                      ? AppColors.primaryBlue
                      : AppColors.textTertiary,
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

/// MODAL DEL SELECTOR VERTICAL DE TRES RODILLOS (Formato 12 horas estricto)
class _VerticalScrollTimePickerModal extends StatefulWidget {
  const _VerticalScrollTimePickerModal({
    required this.initialTime,
    required this.onTimeChanged,
  });

  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  @override
  State<_VerticalScrollTimePickerModal> createState() =>
      _VerticalScrollTimePickerModalState();
}

class _VerticalScrollTimePickerModalState
    extends State<_VerticalScrollTimePickerModal> {
  late int _selectedHour12;
  late int _selectedMinute;
  late String _selectedPeriod; // 'AM' o 'PM'

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  final List<int> _hoursList = List.generate(
    12,
    (index) => index + 1,
  ); // 1 al 12
  final List<int> _minutesList = List.generate(60, (index) => index); // 0 al 59
  final List<String> _periodsList = ['AM', 'PM'];

  @override
  void initState() {
    super.initState();
    // Conversión de 24h a formato 12h para inicializar rodillos
    final hour24 = widget.initialTime.hour;
    _selectedHour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    _selectedMinute = widget.initialTime.minute;
    _selectedPeriod = hour24 < 12 ? 'AM' : 'PM';

    _hourController = FixedExtentScrollController(
      initialItem: _hoursList.indexOf(_selectedHour12),
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _minutesList.indexOf(_selectedMinute),
    );
    _periodController = FixedExtentScrollController(
      initialItem: _periodsList.indexOf(_selectedPeriod),
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _updateParentTime() {
    // Re-convertir de 12 horas a 24 horas para enviar de vuelta al ReservationProvider
    int finalHour24 = _selectedHour12;
    if (_selectedPeriod == 'PM' && _selectedHour12 < 12) {
      finalHour24 += 12;
    } else if (_selectedPeriod == 'AM' && _selectedHour12 == 12) {
      finalHour24 = 0;
    }

    widget.onTimeChanged(TimeOfDay(hour: finalHour24, minute: _selectedMinute));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barra superior de acciones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _updateParentTime();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      'Listo',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            // Contenedor de los rodillos verticales
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Rodillo de Formato AM / PM
                    SizedBox(
                      width: 70,
                      child: ListWheelScrollView.useDelegate(
                        controller: _periodController,
                        itemExtent: 45,
                        perspective: 0.005,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedPeriod = _periodsList[index];
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: _periodsList.length,
                          builder: (context, index) {
                            final isSelected =
                                _selectedPeriod == _periodsList[index];
                            return Center(
                              child: Text(
                                _periodsList[index],
                                style: GoogleFonts.poppins(
                                  fontSize: isSelected ? 24 : 18,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Rodillo de Horas (1-12)
                    SizedBox(
                      width: 70,
                      child: ListWheelScrollView.useDelegate(
                        controller: _hourController,
                        itemExtent: 45,
                        perspective: 0.005,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedHour12 = _hoursList[index];
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: _hoursList.length,
                          builder: (context, index) {
                            final item = _hoursList[index];
                            final isSelected = _selectedHour12 == item;
                            return Center(
                              child: Text(
                                item.toString().padLeft(2, '0'),
                                style: GoogleFonts.poppins(
                                  fontSize: isSelected ? 24 : 18,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Separador de dos puntos
                    Text(
                      ':',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    // Rodillo de Minutos (00-59)
                    SizedBox(
                      width: 70,
                      child: ListWheelScrollView.useDelegate(
                        controller: _minuteController,
                        itemExtent: 45,
                        perspective: 0.005,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedMinute = _minutesList[index];
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: _minutesList.length,
                          builder: (context, index) {
                            final item = _minutesList[index];
                            final isSelected = _selectedMinute == item;
                            return Center(
                              child: Text(
                                item.toString().padLeft(2, '0'),
                                style: GoogleFonts.poppins(
                                  fontSize: isSelected ? 24 : 18,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeRangeBar extends StatelessWidget {
  const _TimeRangeBar({
    required this.blockedRanges,
    required this.startTime,
    required this.endTime,
    required this.minHour,
    required this.maxHour,
  });

  final List<TimeSlot> blockedRanges;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final int minHour;
  final int maxHour;

  @override
  Widget build(BuildContext context) {
    final totalSlots = maxHour - minHour;
    if (totalSlots <= 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disponibilidad del día:',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 28,
            child: Row(
              children: List.generate(totalSlots, (i) {
                final hour = minHour + i;
                final slotStart = hour * 60;
                final slotEnd = (hour + 1) * 60;
                final isBlocked = blockedRanges.any((slot) {
                  final startMin = slot.start.hour * 60 + slot.start.minute;
                  final endMin = slot.end.hour * 60 + slot.end.minute;
                  return (slotStart >= startMin && slotStart < endMin) ||
                      (slotEnd > startMin && slotEnd <= endMin) ||
                      (slotStart <= startMin && slotEnd >= endMin);
                });

                final isSelected =
                    startTime != null &&
                    endTime != null &&
                    hour >= startTime!.hour &&
                    hour < endTime!.hour;

                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isBlocked
                          ? AppColors.error.withValues(alpha: 0.25)
                          : isSelected
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.primaryBlue.withValues(alpha: 0.08),
                      border: i < totalSlots - 1
                          ? const Border(
                              right: BorderSide(
                                color: AppColors.border,
                                width: 0.5,
                              ),
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _formatHourShort(hour),
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: isBlocked
                            ? AppColors.error
                            : isSelected
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _LegendDot(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
            const SizedBox(width: 4),
            const _LegendText('Disponible'),
            const SizedBox(width: 12),
            _LegendDot(color: AppColors.error.withValues(alpha: 0.4)),
            const SizedBox(width: 4),
            const _LegendText('Reservado'),
            const SizedBox(width: 12),
            _LegendDot(color: AppColors.success.withValues(alpha: 0.4)),
            const SizedBox(width: 4),
            const _LegendText('Tu selección'),
          ],
        ),
      ],
    );
  }

  String _formatHourShort(int hour) {
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h$period';
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _LegendText extends StatelessWidget {
  const _LegendText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary),
    );
  }
}
