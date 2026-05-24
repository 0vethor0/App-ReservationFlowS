/// Componente de resumen y confirmación de reservación.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../../../core/widgets/neon_button.dart';
import '../../../providers/reservation_provider.dart';
import 'summary_row.dart';
import 'multiple_reservation_bottom_sheet.dart';

class ReservationSummary extends StatelessWidget {
  const ReservationSummary({super.key, required this.provider});

  final ReservationProvider provider;

  @override
  Widget build(BuildContext context) {
    final startStr = provider.startTime?.format(context) ?? '';
    final endStr = provider.endTime?.format(context) ?? '';

    return NeonCard(
      glowOpacity: 0.15,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.reservationSummary,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SummaryRow(
            icon: Icons.videocam_outlined,
            label: AppStrings.equipment,
            value: provider.selectedVideobeam?.name ?? '',
          ),
          const SizedBox(height: 8),
          SummaryRow(
            icon: Icons.description_outlined,
            label: 'Notas',
            value: provider.notes.isEmpty
                ? 'Sin notas adicionales'
                : provider.notes,
          ),
          const SizedBox(height: 8),
          SummaryRow(
            icon: Icons.calendar_today,
            label: AppStrings.dateAndTime,
            value:
                '${DateFormat('dd MMM yyyy').format(provider.selectedDate)} • $startStr - $endStr',
          ),
          const SizedBox(height: 16),
          NeonButton(
            text: AppStrings.confirmReservation,
            onPressed: () async {
              debugPrint('>>> BOTÓN CONFIRMAR PRESIONADO <<<');
              final success = await provider.confirmReservation();
              debugPrint('Resultado confirmación: $success');

              if (!context.mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Reservación confirmada'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                provider.reset();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.error ?? 'Error desconocido'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            isLoading: provider.isLoading,
          ),
          const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final rpcDates = await MultipleReservationBottomSheet.show(context);
                  if (rpcDates == null) return;

                  final success = await provider.confirmMultipleReservations(
                    rpcDates,
                    'Reserva Recurrente',
                  );

                  if (!context.mounted) return;
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Reservas creadas exitosamente'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    provider.reset();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.error ?? 'Error al realizar reservas múltiples'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.repeat, color: AppColors.primaryBlue),
                label: Text(
                  'Configurar Recurrencia / Reservas Múltiples',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
