import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/reservation_provider.dart';

class ReservationCalendarView extends StatefulWidget {
  const ReservationCalendarView({super.key});

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
      appBar: AppBar(
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
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.reservations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          return SfCalendar(
            controller: _calendarController,
            view: CalendarView.week,
            backgroundColor: AppColors.background,
            firstDayOfWeek: 1, // Lunes
            initialDisplayDate: DateTime.now(),
            dataSource: _ReservationDataSource(provider.reservations),
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
    );
  }
}

class _ReservationDataSource extends CalendarDataSource {
  _ReservationDataSource(List<dynamic> source) {
    appointments = _getAppointments(source);
  }

  List<Appointment> _getAppointments(List<dynamic> source) {
    final List<Appointment> appointments = <Appointment>[];
    final random = Random();

    final List<Color> pastelColors = [
      AppColors.primaryBlue,
      AppColors.success,
      AppColors.warning,
      AppColors.accentOrange,
      Colors.indigo,
      Colors.teal,
      Colors.deepPurple,
      Colors.cyan,
      Colors.pink,
    ];

    for (var reservation in source) {
      // Filtrar solo reservaciones aprobadas por seguridad
      final estadoReserva = reservation['estado_reserva'] as String? ?? '';
      if (estadoReserva != 'aprobada') {
        continue;
      }

      if (reservation['hora_inicio'] != null &&
          reservation['hora_fin'] != null) {
        try {
          // Parsear la hora de inicio
          final String startTimeStr = reservation['hora_inicio'] as String;
          DateTime startTime = DateTime.parse(startTimeStr);

          // Parsear la hora de fin
          final String endTimeStr = reservation['hora_fin'] as String;
          DateTime endTime = DateTime.parse(endTimeStr);

          // Ajuste de timezone: Supabase retorna UTC, convertimos a hora local
          // Esto asegura que las horas se muestren correctamente en la zona horaria del usuario
          startTime = startTime.toLocal();
          endTime = endTime.toLocal();

          final String productName =
              reservation['productos'] != null &&
                  reservation['productos']['nombre'] != null
              ? reservation['productos']['nombre']
              : 'Reserva';

          final String location =
              reservation['productos'] != null &&
                  reservation['productos']['ubicacion'] != null
              ? reservation['productos']['ubicacion']
              : '';

          final Color randomColor =
              pastelColors[random.nextInt(pastelColors.length)];

          appointments.add(
            Appointment(
              startTime: startTime,
              endTime: endTime,
              subject: location.isNotEmpty
                  ? '$productName - $location'
                  : productName,
              color: randomColor,
              isAllDay: false,
            ),
          );
        } catch (e) {
          debugPrint('Error parsing reservation time: $e');
        }
      }
    }
    return appointments;
  }
}
