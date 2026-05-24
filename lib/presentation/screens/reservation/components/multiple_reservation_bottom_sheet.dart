// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_button.dart';
import '../../../providers/reservation_provider.dart';

class MultipleReservationBottomSheet extends StatefulWidget {
  const MultipleReservationBottomSheet({super.key});

  static Future<List<Map<String, dynamic>>?> show(BuildContext context) {
    return showMaterialModalBottomSheet<List<Map<String, dynamic>>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const MultipleReservationBottomSheet(),
    );
  }

  @override
  State<MultipleReservationBottomSheet> createState() =>
      _MultipleReservationBottomSheetState();
}

class _MultipleReservationBottomSheetState
    extends State<MultipleReservationBottomSheet> {
  String _selectedOption = 'mismo_dia_mes';

  String _getDayName(int weekday) {
    return switch (weekday) {
      1 => 'lunes',
      2 => 'martes',
      3 => 'miércoles',
      4 => 'jueves',
      5 => 'viernes',
      6 => 'sábado',
      7 => 'domingo',
      _ => '',
    };
  }

  List<DateTime> _generateDates(DateTime baseDate, String option) {
    final List<DateTime> dates = [];
    if (option == 'mismo_dia_mes') {
      final int targetWeekday = baseDate.weekday;
      DateTime current = DateTime(baseDate.year, baseDate.month, 1);
      while (current.month == baseDate.month) {
        if (current.weekday == targetWeekday && 
            current.isAfter(baseDate.subtract(const Duration(days: 1)))) {
          dates.add(current);
        }
        current = current.add(const Duration(days: 1));
      }
    } else if (option == 'toda_la_semana') {
       DateTime current = baseDate;
       for(int i = 0; i < 5; i++) {
         if (current.month == baseDate.month) {
           dates.add(current);
         }
         current = current.add(const Duration(days: 1));
       }
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservationProvider>();
    final baseDate = provider.selectedDate;
    final dayName = _getDayName(baseDate.weekday);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurar Recurrencia',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: Text('Todos los $dayName del mes', style: GoogleFonts.inter(color: AppColors.textPrimary)),
              value: 'mismo_dia_mes',
              groupValue: _selectedOption,
              activeColor: AppColors.primaryBlue,
              onChanged: (val) {
                setState(() {
                  _selectedOption = val!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('5 días seguidos desde fecha seleccionada', style: GoogleFonts.inter(color: AppColors.textPrimary)),
              value: 'toda_la_semana',
              groupValue: _selectedOption,
              activeColor: AppColors.primaryBlue,
              onChanged: (val) {
                setState(() {
                  _selectedOption = val!;
                });
              },
            ),
            const SizedBox(height: 24),
            NeonButton(
              text: 'Confirmar Reservas Múltiples',
              onPressed: () async {
                final dates = _generateDates(baseDate, _selectedOption);
                if (dates.isEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No hay fechas válidas para esta opción')),
                  );
                  return;
                }

                if (provider.startTime == null || provider.endTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Debe seleccionar horario en la pantalla anterior')),
                  );
                  return;
                }

                final List<Map<String, dynamic>> rpcDates = dates.map((d) {
                  final start = DateTime(d.year, d.month, d.day, provider.startTime!.hour, provider.startTime!.minute);
                  final end = DateTime(d.year, d.month, d.day, provider.endTime!.hour, provider.endTime!.minute);
                  return {
                    'inicio': start.toIso8601String(),
                    'fin': end.toIso8601String(),
                    'notas': provider.notes,
                  };
                }).toList();

                Navigator.pop(context, rpcDates);
              },
            ),
          ],
        ),
      ),
    );
  }
}
