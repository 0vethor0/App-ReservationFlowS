/// Tile para mostrar una reservación upcoming.
/// El tile muestra la hora de inicio, la ubicación y el nombre del videobeam.
/// El tile se utiliza en la pantalla de dashboard para mostrar las reservaciones upcoming.
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_card.dart';

class UpcomingReservationTile extends StatelessWidget {
  const UpcomingReservationTile({
    super.key,
    required this.reservation,
  });

  final dynamic reservation;

  @override
  Widget build(BuildContext context) {
    final startTimeRaw = reservation['hora_inicio'] as String? ?? '';
    final locationRaw =
        reservation['productos']?['ubicacion'] as String? ?? 'Desconocida';
    final videobeamNameRaw =
        reservation['productos']?['nombre'] as String? ?? 'Videobeam';

    String formattedTime = '';
    try {
      if (startTimeRaw.isNotEmpty) {
        final dt = DateTime.parse(startTimeRaw).toLocal();
        formattedTime =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      formattedTime = startTimeRaw;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'HOY',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  Text(
                    formattedTime,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locationRaw,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    videobeamNameRaw,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.lightBlue,
              child: Text(
                'U',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}