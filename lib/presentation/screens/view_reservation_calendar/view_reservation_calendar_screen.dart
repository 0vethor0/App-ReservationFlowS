import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../providers/view_reservation_calendar_provider.dart';
import '../../../../features/reservations/domain/entities/reservation_entity.dart';

class ViewReservationCalendarScreen extends StatefulWidget {
  const ViewReservationCalendarScreen({super.key, required this.onGoToReserve});

  final VoidCallback onGoToReserve;

  @override
  State<ViewReservationCalendarScreen> createState() =>
      _ViewReservationCalendarScreenState();
}

class _ViewReservationCalendarScreenState
    extends State<ViewReservationCalendarScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewReservationCalendarProvider>(
      builder: (context, provider, _) {
        final dateStr = DateFormat(
          'EEEE, d '
              'de'
              ' MMMM',
          'es',
        ).format(provider.selectedDate);

        return Column(
          children: [
            // Main scrollable content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Header Section
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lista de Reservaciones Globales',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Upper Section: Weekly Calendar Card with "Ampliar calendario" button
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 100),
                    child: NeonCard(
                      padding: const EdgeInsets.all(12),
                      glowOpacity: 0.03,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // "Ampliar calendario" button at top-left
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  context.push('/reservation-calendar'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryBlue,
                                      AppColors.primaryBlue.withValues(
                                        alpha: 0.85,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.open_in_full_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      AppStrings.expandCalendar,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Calendar widget
                          TableCalendar(
                            locale: 'es_ES',
                            firstDay: DateTime.now().subtract(
                              const Duration(days: 30),
                            ),
                            lastDay: DateTime.now().add(
                              const Duration(days: 90),
                            ),
                            focusedDay: provider.selectedDate,
                            currentDay: provider.selectedDate,
                            calendarFormat: CalendarFormat.week,
                            availableCalendarFormats: const {
                              CalendarFormat.week: 'Semana',
                            },
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            headerStyle: HeaderStyle(
                              titleTextStyle: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              formatButtonVisible: false,
                              leftChevronIcon: const Icon(
                                Icons.chevron_left,
                                color: AppColors.primaryBlue,
                              ),
                              rightChevronIcon: const Icon(
                                Icons.chevron_right,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            calendarStyle: CalendarStyle(
                              defaultTextStyle: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                              ),
                              weekendTextStyle: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                              ),
                              todayDecoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(
                                  alpha: 0.2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            onDaySelected: (selectedDay, focusedDay) {
                              provider.selectDate(selectedDay);
                            },
                            selectedDayPredicate: (day) =>
                                isSameDay(provider.selectedDate, day),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Filter Chips Section (without "Canceladas")
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateStr.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Text(
                              '${provider.filteredReservations.length} reservas',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'Aprobadas',
                                isActive:
                                    provider.selectedFilter == 'Aprobadas',
                                onTap: () => provider.selectFilter('Aprobadas'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'En curso',
                                isActive: provider.selectedFilter == 'En curso',
                                onTap: () => provider.selectFilter('En curso'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Finalizadas',
                                isActive:
                                    provider.selectedFilter == 'Finalizadas',
                                onTap: () =>
                                    provider.selectFilter('Finalizadas'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Lower Section: Detailed Reservations List
                  Expanded(
                    child: provider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                            ),
                          )
                        : provider.error != null
                        ? Center(
                            child: Text(
                              provider.error!,
                              style: GoogleFonts.inter(color: Colors.red[600]),
                            ),
                          )
                        : provider.filteredReservations.isEmpty
                        ? FadeIn(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 48,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No hay reservaciones en este estado',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: provider.filteredReservations.length,
                            padding: const EdgeInsets.only(bottom: 16),
                            itemBuilder: (context, index) {
                              final res = provider.filteredReservations[index];
                              return FadeInUp(
                                duration: const Duration(milliseconds: 300),
                                delay: Duration(milliseconds: index * 50),
                                child: _ReservationDetailCard(reservation: res),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // Fixed animated reservation button at the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: GestureDetector(
                    onTap: widget.onGoToReserve,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryBlue, Color(0xFF3D8BFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(
                              alpha: 0.45,
                            ),
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(
                              alpha: 0.15,
                            ),
                            blurRadius: 40,
                            spreadRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_circle_outline_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'Haz tu reservación aquí, pulsa el botón',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: AppColors.border.withValues(alpha: 0.15)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ReservationDetailCard extends StatelessWidget {
  const _ReservationDetailCard({required this.reservation});

  final ReservationEntity reservation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: reservation.userAvatarUrl != null
                      ? NetworkImage(reservation.userAvatarUrl!)
                      : null,
                  backgroundColor: AppColors.surfaceLight,
                  child: reservation.userAvatarUrl == null
                      ? const Icon(
                          Icons.person,
                          color: AppColors.textSecondary,
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.userName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        reservation.department ?? 'Usuario',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: reservation.status),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.videocam_rounded,
                        size: 16,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Proyector: ',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          reservation.videobeamName,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled_rounded,
                        size: 16,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Horario: ',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${reservation.startTime} - ${reservation.endTime}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (reservation.notes != null && reservation.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Notas del propósito:',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                reservation.notes!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textPrimary,
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
  const _StatusBadge({required this.status});

  final ReservationStatus status;

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
