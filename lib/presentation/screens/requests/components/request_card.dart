import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/entities.dart';
import '../../../providers/requests_provider.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.request,
    required this.provider,
  });

  final ReservationEntity request;
  final RequestsProvider provider;

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == ReservationStatus.pending;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            // Header: Avatar, Info, Status Badge
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: request.userAvatarUrl != null
                      ? NetworkImage(request.userAvatarUrl!)
                      : null,
                  backgroundColor: AppColors.surfaceLight,
                  child: request.userAvatarUrl == null
                      ? const Icon(Icons.person, color: AppColors.textSecondary)
                      : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.userName,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.department ?? 'Usuario',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: 20),

            // Info Box: Equipment
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.videocam_rounded,
                      label: 'EQUIPO',
                      value: request.videobeamName,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Date and Time separated blocks
            Row(
              children: [
                Expanded(
                  child: _DateTimeBlock(
                    icon: Icons.calendar_today,
                    label: 'FECHA',
                    value: _formatDate(request),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateTimeBlock(
                    icon: Icons.access_time_filled,
                    label: 'HORA',
                    value: '${request.startTime} - ${request.endTime}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Purpose / Notes
            if (request.notes != null && request.notes!.isNotEmpty) ...[
              Text(
                'Propósito',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                request.notes!,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF2D2D2D),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Actions
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      text: 'Declinar',
                      onPressed: () => provider.rejectRequest(request.id),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _ActionButton(
                      text: 'Aprobar',
                      onPressed: () => provider.approveRequest(request.id),
                      isPrimary: true,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(ReservationEntity req) {
    final now = DateTime.now();
    String day = '';
    if (req.date.year == now.year &&
        req.date.month == now.month &&
        req.date.day == now.day) {
      day = 'Hoy';
    } else if (req.date.year == now.year &&
        req.date.month == now.month &&
        req.date.day == now.day + 1) {
      day = 'Mañana';
    } else {
      day = DateFormat('dd MMM yyyy').format(req.date);
    }
    return day;
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D2D2D),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateTimeBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DateTimeBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2D2D),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ActionButton({
    required this.text,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF007BFF) : Colors.transparent,
        side: BorderSide(
          color: isPrimary ? const Color(0xFF007BFF) : Colors.grey[300]!,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isPrimary ? Colors.white : const Color(0xFF2D2D2D),
        ),
      ),
    );
  }
}