import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../../features/reservations/domain/entities/reservation_entity.dart';

class UtilizationChart extends StatefulWidget {
  const UtilizationChart({super.key});

  @override
  State<UtilizationChart> createState() => _UtilizationChartState();
}

class _UtilizationChartState extends State<UtilizationChart> {
  @override
  void initState() {
    super.initState();
    // Setup notification callback via provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashProvider = context.read<DashboardProvider>();
      dashProvider.onNewReservation = _mostrarNotificacion;
    });
  }

  void _mostrarNotificacion(Map<String, dynamic> reserva) {
    final nombre = reserva['perfiles']?['primer_nombre'] ?? 'Usuario';
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nueva solicitud de $nombre'),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usar context.watch() para escuchar cambios en el provider
    final dashProvider = context.watch<DashboardProvider>();

    return Builder(
      builder: (context) {
        final dateStr = DateFormat(
          'dd MMM yyyy',
        ).format(dashProvider.filterDate);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 150,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 20),
                        onPressed: dashProvider.previousDate,
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
                        onPressed: dashProvider.nextDate,
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

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusFilterChip(
                    label: AppStrings.pending,
                    isActive: dashProvider.myReservationsFilter == 'Pendientes',
                    onTap: () =>
                        dashProvider.setMyReservationsFilter('Pendientes'),
                  ),
                  const SizedBox(width: 8),
                  _StatusFilterChip(
                    label: AppStrings.approved,
                    isActive: dashProvider.myReservationsFilter == 'Aprobadas',
                    onTap: () =>
                        dashProvider.setMyReservationsFilter('Aprobadas'),
                  ),
                  const SizedBox(width: 8),
                  _StatusFilterChip(
                    label: AppStrings.inProgress,
                    isActive: dashProvider.myReservationsFilter == 'En curso',
                    onTap: () =>
                        dashProvider.setMyReservationsFilter('En curso'),
                  ),
                  const SizedBox(width: 8),
                  _StatusFilterChip(
                    label: AppStrings.cancelled,
                    isActive: dashProvider.myReservationsFilter == 'Canceladas',
                    onTap: () =>
                        dashProvider.setMyReservationsFilter('Canceladas'),
                  ),
                  const SizedBox(width: 8),
                  _StatusFilterChip(
                    label: AppStrings.completed,
                    isActive:
                        dashProvider.myReservationsFilter == 'Finalizadas',
                    onTap: () =>
                        dashProvider.setMyReservationsFilter('Finalizadas'),
                  ),
                  const SizedBox(width: 8),
                  _StatusFilterChip(
                    label: AppStrings.rejected,
                    isActive: dashProvider.myReservationsFilter == 'Rechazadas',
                    onTap: () =>
                        dashProvider.setMyReservationsFilter('Rechazadas'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (dashProvider.isLoadingMyReservations)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                ),
              )
            else if (dashProvider.filteredMyReservations.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    'No hay reservaciones',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dashProvider.filteredMyReservations.length,
                itemBuilder: (context, index) {
                  final reservation =
                      dashProvider.filteredMyReservations[index];
                  return FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: Duration(milliseconds: index * 100),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 0),
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
    final isRead = request.isRead;
    final createdAt = request.createdAt;

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
      child: Stack(
        children: [
          Padding(
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
                          ? const Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                            )
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
                        value:
                            '${DateFormat('dd MMM').format(request.date)}, ${request.startTime} - ${request.endTime}',
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
                if (request.status == ReservationStatus.inProgress) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _confirmCancel(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.red[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            AppStrings.cancelReservation,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _confirmComplete(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.amber[600]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            AppStrings.completeReservation,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (createdAt != null)
            Positioned(
              top: 15,
              right: 15,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('hh:mm a').format(createdAt),
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 16,
                    color: isRead ? Colors.blue : Colors.grey,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.cancelConfirmTitle),
        content: const Text(AppStrings.cancelConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DashboardProvider>().cancelMyReservation(request.id);
            },
            child: const Text(
              AppStrings.confirm,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmComplete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.completeConfirmTitle),
        content: const Text(AppStrings.completeConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DashboardProvider>().completeMyReservation(
                request.id,
              );
            },
            child: Text(
              AppStrings.confirm,
              style: TextStyle(color: Colors.amber[700]),
            ),
          ),
        ],
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
      case ReservationStatus.inProgress:
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        text = 'EN CURSO';
        break;
      case ReservationStatus.completed:
        bgColor = const Color(0xFFF3E5F5);
        textColor = const Color(0xFF7B1FA2);
        text = 'FINALIZADA';
        break;
      case ReservationStatus.cancelled:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        text = 'CANCELADA';
        break;
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

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primaryBlue.withValues(alpha: 0.6),
        ),
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

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
