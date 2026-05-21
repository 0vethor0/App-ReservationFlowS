import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/reservations/domain/entities/reservation_entity.dart';
import '../../../features/view_reservation_calendar/domain/entities/calendar_status_filter.dart';
import '../../providers/reservation_calendar_provider.dart';
import '../../widgets/calendar_filter_bar.dart';

class ReservationCalendarView extends StatefulWidget {
  const ReservationCalendarView({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<ReservationCalendarView> createState() =>
      _ReservationCalendarViewState();
}

class _ReservationCalendarViewState extends State<ReservationCalendarView> {
  final CalendarController _calendarController = CalendarController();

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: AppColors.surfaceLight,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Calendario de Reservas',
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              actions: [
                PopupMenuButton<CalendarView>(
                  icon: const Icon(
                    Icons.calendar_view_month,
                    color: AppColors.primaryBlue,
                  ),
                  onSelected: (CalendarView view) {
                    _calendarController.view = view;
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<CalendarView>>[
                        const PopupMenuItem<CalendarView>(
                          value: CalendarView.day,
                          child: Text('Día'),
                        ),
                        const PopupMenuItem<CalendarView>(
                          value: CalendarView.week,
                          child: Text('Semana'),
                        ),
                        const PopupMenuItem<CalendarView>(
                          value: CalendarView.month,
                          child: Text('Mes'),
                        ),
                      ],
                ),
              ],
            )
          : null,
      body: Consumer<ReservationCalendarProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.reservations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          if (provider.error != null && provider.reservations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: AppColors.error),
                ),
              ),
            );
          }

          return SfCalendar(
            controller: _calendarController,
            view: CalendarView.week,
            backgroundColor: AppColors.background,
            firstDayOfWeek: 1,
            initialDisplayDate: DateTime.now(),
            dataSource: _ReservationDataSource(
              provider.reservations,
              provider.statusFilter,
            ),
            allowDragAndDrop: false,
            allowAppointmentResize: false,
            cellBorderColor: AppColors.border.withValues(alpha: 0.1),
            selectionDecoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: AppColors.primaryBlue, width: 2),
            ),
            timeSlotViewSettings: TimeSlotViewSettings(
              startHour: 7,
              endHour: 22,
              timeTextStyle: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              timeRulerSize: 60,
            ),
            headerStyle: CalendarHeaderStyle(
              textStyle: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            viewHeaderStyle: ViewHeaderStyle(
              dayTextStyle: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              dateTextStyle: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            monthViewSettings: MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              monthCellStyle: MonthCellStyle(
                textStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<ReservationCalendarProvider>(
        builder: (context, provider, _) {
          return CalendarFilterBar(
            products: provider.products,
            selectedProductId: provider.selectedProductId,
            selectedStatus: provider.statusFilter,
            onProductSelected: provider.selectProduct,
            onStatusSelected: provider.selectStatusFilter,
          );
        },
      ),
    );
  }
}

class _ReservationDataSource extends CalendarDataSource {
  _ReservationDataSource(
    List<ReservationEntity> source,
    CalendarStatusFilter statusFilter,
  ) {
    appointments = _getAppointments(source, statusFilter);
  }

  List<Appointment> _getAppointments(
    List<ReservationEntity> source,
    CalendarStatusFilter statusFilter,
  ) {
    final appointments = <Appointment>[];

    for (final reservation in source) {
      try {
        final startTime = reservation.date;
        final endTime = reservation.endDateTime;
        if (endTime == null || !endTime.isAfter(startTime)) continue;

        final subject = reservation.videobeamName;

        appointments.add(
          Appointment(
            startTime: startTime,
            endTime: endTime,
            subject: subject,
            color: _colorForFilter(statusFilter),
            isAllDay: false,
          ),
        );
      } catch (e) {
        debugPrint('Error parsing reservation: $e');
      }
    }
    return appointments;
  }

  Color _colorForFilter(CalendarStatusFilter filter) {
    switch (filter) {
      case CalendarStatusFilter.approved:
        return AppColors.primaryBlue;
      case CalendarStatusFilter.inProgress:
        return AppColors.warning;
      case CalendarStatusFilter.completed:
        return AppColors.success;
    }
  }
}
