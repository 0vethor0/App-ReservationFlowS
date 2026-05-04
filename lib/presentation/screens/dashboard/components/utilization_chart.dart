import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/dashboard_provider.dart';
import '../../requests/components/request_card.dart';
import '../../../../domain/entities/entities.dart';

class UtilizationChart extends StatelessWidget {
  const UtilizationChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final dateStr = DateFormat('dd MMM yyyy').format(provider.filterDate);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Arrows Filter
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 150, // Minimum width for the title
                  child: Text(
                    'MIS RESERVACIONES',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 20),
                        onPressed: provider.previousDate,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        color: AppColors.primaryBlue,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          dateStr,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 20),
                        onPressed: provider.nextDate,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        color: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reservations List
            if (provider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                ),
              )
            else if (provider.myReservations.isEmpty)
              FadeIn(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy_rounded, size: 48, color: AppColors.textTertiary.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes solicitudes para esta fecha',
                        style: GoogleFonts.inter(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.myReservations.length,
                itemBuilder: (context, index) {
                  final reservation = provider.myReservations[index];
                  return FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: Duration(milliseconds: index * 100),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      // Usamos el RequestCard pero el DashboardProvider no tiene approve/reject
                      // por lo que no pasarán las acciones si el RequestCard las requiere.
                      // Nota: El RequestCard original recibe RequestsProvider, pero aquí
                      // solo queremos visualizar. Rediseñaré el RequestCard para ser más flexible
                      // o crearé una versión simplificada aquí.
                      child: DashboardRequestCard(request: reservation),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class DashboardRequestCard extends StatelessWidget {
  final ReservationEntity request;

  const DashboardRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: request.userAvatarUrl != null
                      ? NetworkImage(request.userAvatarUrl!)
                      : null,
                  backgroundColor: AppColors.surfaceLight,
                  child: request.userAvatarUrl == null
                      ? const Icon(Icons.person, color: AppColors.textSecondary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.userName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        request.department ?? 'Usuario',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.videocam_rounded,
                    label: 'Equipo',
                    value: request.videobeamName,
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.access_time_filled_rounded,
                    label: 'Horario',
                    value: '${DateFormat('dd MMM').format(request.date)}, ${request.startTime} - ${request.endTime}',
                  ),
                ],
              ),
            ),
            if (request.notes != null && request.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Propósito',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                request.notes!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF2D2D2D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ReservationStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case ReservationStatus.pending:
        bgColor = const Color(0xFFFFF9E6);
        textColor = const Color(0xFFB38600);
        text = 'PENDIENTE';
        break;
      case ReservationStatus.approved:
        bgColor = const Color(0xFFE6F4EA);
        textColor = const Color(0xFF1E7E34);
        text = 'APROBADA';
        break;
      case ReservationStatus.rejected:
        bgColor = const Color(0xFFFDE8E8);
        textColor = const Color(0xFFC81E1E);
        text = 'RECHAZADA';
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[600]!;
        text = 'OTRO';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryBlue.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2D2D),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}