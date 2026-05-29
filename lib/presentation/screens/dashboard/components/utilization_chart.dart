import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../../features/reservations/domain/entities/reservation_entity.dart';
import '../../../../features/messaging/presentation/providers/messaging_provider.dart';
import '../dashboard_screen.dart';

class UtilizationChart extends StatefulWidget {
  const UtilizationChart({super.key});

  @override
  State<UtilizationChart> createState() => _UtilizationChartState();
}

class _UtilizationChartState extends State<UtilizationChart> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null);// para que el datepicker muestre la fecha en español
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

  void _showDatePicker(BuildContext context, DashboardProvider dashProvider) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6.0),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: CupertinoTheme(
            data: CupertinoThemeData(
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Text('Aceptar', style: TextStyle(color: AppColors.primaryBlue)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: dashProvider.filterDate,
                      onDateTimeChanged: (DateTime newDate) {
                        dashProvider.setFilterDate(newDate);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usar context.watch() para escuchar cambios en el provider
    final dashProvider = context.watch<DashboardProvider>();

    return Builder(
      builder: (context) {
        final dateStr = DateFormat(
          "dd'/'MM'/'yyyy",
          'es',
        ).format(dashProvider.filterDate);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MIS RESERVACIONES',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ArrowButton(
                        icon: Icons.chevron_left,
                        onPressed: dashProvider.previousDate,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showDatePicker(context, dashProvider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 8, 122, 235),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    dateStr,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.calendar_month,
                                  size: 18,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _ArrowButton(
                        icon: Icons.chevron_right,
                        onPressed: dashProvider.nextDate,
                      ),
                    ],
                  ),
                ],
              ),
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
    File? selectedEvidence;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (innerCtx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(innerCtx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Icon(Icons.camera_alt_rounded, size: 48, color: AppColors.primaryBlue),
                      const SizedBox(height: 12),
                      Text(
                        'Evidencia fotográfica',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Para finalizar la reservación, adjunta una foto del equipo en su estado actual.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),

                      // Image preview or picker
                      if (selectedEvidence != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                selectedEvidence!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setModalState(() => selectedEvidence = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: _EvidencePickerButton(
                                icon: Icons.camera_alt_outlined,
                                label: 'Cámara',
                                onTap: () async {
                                  final xfile = await ImagePicker().pickImage(
                                    source: ImageSource.camera,
                                    imageQuality: 70,
                                  );
                                  if (xfile != null) {
                                    setModalState(() => selectedEvidence = File(xfile.path));
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _EvidencePickerButton(
                                icon: Icons.photo_library_outlined,
                                label: 'Galería',
                                onTap: () async {
                                  final xfile = await ImagePicker().pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 70,
                                  );
                                  if (xfile != null) {
                                    setModalState(() => selectedEvidence = File(xfile.path));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // Send button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: selectedEvidence == null
                              ? null
                              : () {
                                  final msgProvider = context.read<MessagingProvider>();
                                  final dashProvider = context.read<DashboardProvider>();

                                  // 1. Set image for optimistic upload
                                  msgProvider.selectImage(selectedEvidence!);

                                  // 2. Close modal
                                  Navigator.pop(innerCtx);

                                  // 3. Get or create canal for this reservation, then navigate
                                  msgProvider.loadCanales().then((_) async {
                                    try {
                                      if (!context.mounted) return;
                                      await msgProvider.openCanalForReserva(request.id);

                                      // Send evidence optimistically
                                      await msgProvider.enviarMensaje(
                                        'Evidencia fotográfica - Finalización de reserva',
                                      );

                                      // Complete reservation in DB
                                      dashProvider.completeMyReservation(request.id);

                                      // Navigate to Chat tab (index 3 in dashboard)
                                      if (!context.mounted) return;
                                      _navigateToChatTab(context);
                                    } catch (e) {
                                      debugPrint('Error enviando evidencia: $e');
                                    }
                                  });
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Enviar y Finalizar',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(innerCtx),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Notifies the DashboardScreen to switch to Chat tab (index 3).
  void _navigateToChatTab(BuildContext context) {
    final dashState = context.findAncestorStateOfType<DashboardScreenState>();
    if (dashState != null && dashState.mounted) {
      dashState.switchToTab(3);
    }
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

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ArrowButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _EvidencePickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _EvidencePickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: AppColors.primaryBlue),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
