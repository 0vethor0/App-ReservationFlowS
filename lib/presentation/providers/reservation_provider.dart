library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/reservations/domain/repositories/reservation_repository.dart';
import '../../features/reservations/domain/entities/videobeam_entity.dart';
import '../../features/reservations/domain/entities/time_slot.dart';

class ReservationProvider extends ChangeNotifier {
  ReservationProvider(this._reservationRepository) {
    _loadVideobeams();
    _productAvailabilitySubscription = _reservationRepository
        .watchProductAvailability()
        .listen((_) {
          debugPrint(
            '[ReservationProvider] Disponibilidad actualizada (realtime)',
          );
          _loadVideobeams();
        });
  }

  final ReservationRepository _reservationRepository;
  StreamSubscription<void>? _productAvailabilitySubscription;

  List<VideobeamEntity> _videobeams = [];
  List<dynamic> _reservations = [];
  VideobeamEntity? _selectedVideobeam;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;
  String? _error;
  String _notes = '';

  // Arreglo finito dinámico para el día en pantalla
  List<TimeSlot> _bloquesOcupadosDelDia = [];
  List<TimeSlot> get bloquesOcupadosDelDia => _bloquesOcupadosDelDia;

  // Suscripción al Stream de Supabase para poder cancelarla dinámicamente
  StreamSubscription? _reservasRealtimeSubscription;

  List<VideobeamEntity> get videobeams => _videobeams;
  List<dynamic> get reservations => _reservations;
  VideobeamEntity? get selectedVideobeam => _selectedVideobeam;
  DateTime get selectedDate => _selectedDate;
  TimeOfDay? get startTime => _startTime;
  TimeOfDay? get endTime => _endTime;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get notes => _notes;

  Future<void> _loadVideobeams() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('[ReservationProvider] Loading videobeams...');
      _videobeams = await _reservationRepository.loadAllVideobeams();
      debugPrint(
        '[ReservationProvider] Loaded ${_videobeams.length} videobeams',
      );
      await fetchReservations();
    } catch (e, stackTrace) {
      debugPrint('[ReservationProvider] Error loading videobeams: $e');
      debugPrint('[ReservationProvider] Stack trace: $stackTrace');
      _error = 'Error loading videobeams: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectVideobeam(VideobeamEntity videobeam) {
    _selectedVideobeam = videobeam;
    escucharReservasPorDia(videobeam.id, _selectedDate);
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    if (_selectedVideobeam != null) {
      escucharReservasPorDia(_selectedVideobeam!.id, date);
    }
    _startTime = null;
    _endTime = null;
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    _startTime = time;
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    _endTime = time;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  Future<bool> confirmReservation() async {
    if (_selectedVideobeam == null || _startTime == null || _endTime == null) {
      _error = 'Selecciona un equipo y un horario (inicio y fin)';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      final existingReservations = await _reservationRepository
          .fetchApprovedReservationsForProductOnDate(
            videobeamId: _selectedVideobeam!.id,
            date: _selectedDate,
          );

      if (existingReservations.isNotEmpty) {
        final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
        final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

        for (final reservation in existingReservations) {
          final existingStart = DateTime.parse(
            reservation['hora_inicio'] as String,
          );
          final existingEnd = DateTime.parse(
            reservation['hora_fin'] as String,
          );

          final existingStartMinutes =
              existingStart.hour * 60 + existingStart.minute;
          final existingEndMinutes =
              existingEnd.hour * 60 + existingEnd.minute;

          if ((startMinutes >= existingStartMinutes &&
                  startMinutes < existingEndMinutes) ||
              (endMinutes > existingStartMinutes &&
                  endMinutes <= existingEndMinutes) ||
              (startMinutes <= existingStartMinutes &&
                  endMinutes >= existingEndMinutes)) {
            final existingDate = existingStart.day;
            final existingMonth = existingStart.month;
            final existingYear = existingStart.year;

            if (existingDate == _selectedDate.day &&
                existingMonth == _selectedDate.month &&
                existingYear == _selectedDate.year) {
              _isLoading = false;
              _error =
                  'El bloque de horas seleccionado ya está reservado por otro usuario';
              notifyListeners();
              return false;
            }
          }
        }
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final profileId = await _reservationRepository.getProfileIdByEmail(
        user.email!,
      );

      debugPrint(
        'Confirmando reserva via RPC: id_producto=${_selectedVideobeam!.id}, id_usuario=$profileId',
      );
      debugPrint('Horario: $startDateTime - $endDateTime');

      final success = await _reservationRepository.createReservationViaRPC(
        userId: profileId,
        videobeamId: _selectedVideobeam!.id,
        startTime: startDateTime,
        endTime: endDateTime,
        notes: _notes.isNotEmpty ? _notes : null,
      );

      if (!success) {
        throw Exception('No se pudo crear la reserva');
      }

      debugPrint('Reserva insertada con éxito via RPC');

      _isLoading = false;
      _error = null;
      await fetchReservations();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error confirmando reserva: $e');
      _isLoading = false;
      _error = 'Error confirmando reserva: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmMultipleReservations(
    List<Map<String, dynamic>> dates,
    String? globalNotes,
  ) async {
    if (_selectedVideobeam == null || dates.isEmpty) {
      _error = 'Selecciona un equipo y al menos una fecha/horario';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final profileId = await _reservationRepository.getProfileIdByEmail(
        user.email!,
      );

      final success = await _reservationRepository.createMultipleReservations(
        userId: profileId,
        productId: _selectedVideobeam!.id,
        dates: dates,
        globalNotes: globalNotes,
      );

      if (!success) {
        throw Exception('No se pudo crear la reserva múltiple');
      }

      _isLoading = false;
      _error = null;
      await fetchReservations();
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Error confirmando reservas múltiples: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchReservations() async {
    try {
      _reservations = await _reservationRepository.fetchApprovedReservations();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching reservations: $e');
    }
  }

  Future<bool> deleteReservation(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _reservationRepository.deleteReservation(id);
      if (success) {
        await fetchReservations();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = 'Error eliminando reserva: $e';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _selectedVideobeam = null;
    _selectedDate = DateTime.now();
    _startTime = null;
    _endTime = null;
    _notes = '';
    _error = null;
    notifyListeners();
  }

  void escucharReservasPorDia(String productoId, DateTime fechaSeleccionada) {
    _reservasRealtimeSubscription?.cancel();
    _bloquesOcupadosDelDia.clear();

    // 1. Definimos el inicio y fin del día usando la fecha puramente local (00:00:00 a 23:59:59)
    final inicioDiaLocal = DateTime(fechaSeleccionada.year, fechaSeleccionada.month, fechaSeleccionada.day, 0, 0, 0);
    final finDiaLocal = DateTime(fechaSeleccionada.year, fechaSeleccionada.month, fechaSeleccionada.day, 23, 59, 59);

    // 2. Abrimos el canal de Supabase
    _reservasRealtimeSubscription = Supabase.instance.client
        .from('reservas')
        .stream(primaryKey: ['id'])
        .eq('id_producto', productoId)
        .listen((List<Map<String, dynamic>> snapshot) {
      
        final List<TimeSlot> nuevosBloques = [];

        for (var data in snapshot) {
          final estado = data['estado_reserva'] as String?;
          final validStatus = ['aprobada', 'en_curso', 'finalizada'];
          
          if (estado != null && validStatus.contains(estado) && data['hora_inicio'] != null && data['hora_fin'] != null) {
            // Convertimos la hora UTC de la base de datos directamente a la hora local del dispositivo
            final DateTime horaInicioLocal = DateTime.parse(data['hora_inicio']).toLocal();
            final DateTime horaFinLocal = DateTime.parse(data['hora_fin']).toLocal();

            // Comparamos manzanas con manzanas (Hora Local vs Fronteras Locales)
            if (horaInicioLocal.isAfter(inicioDiaLocal) && horaInicioLocal.isBefore(finDiaLocal)) {
              nuevosBloques.add(TimeSlot(start: horaInicioLocal, end: horaFinLocal));
            }
          }
        }

        _bloquesOcupadosDelDia = nuevosBloques;
        notifyListeners(); // Notifica a la UI para repintar los cuadros en su posición real
      }, onError: (error) {
        debugPrint('Error en el stream de reservas: $error');
      });
  }

  /// Cancela la escucha activa (Llamar en el dispose del Screen o widget)
  void limpiarEscuchaRealtime() {
    _reservasRealtimeSubscription?.cancel();
    _bloquesOcupadosDelDia.clear();
  }

  /// Verifica matemáticamente si el rango propuesto choca con algún bloque ocupado local
  bool tieneConflictoDeHorario(DateTime horaInicioPropuesta, DateTime horaFinPropuesta) {
    // Forzamos que los parámetros de entrada estén en hora local para la comparación
    final inicioLocal = horaInicioPropuesta.toLocal();
    final finLocal = horaFinPropuesta.toLocal();

    for (var bloque in _bloquesOcupadosDelDia) {
      // El bloque ya viene en formato .toLocal() desde el stream corregido
      if (inicioLocal.isBefore(bloque.end) && finLocal.isAfter(bloque.start)) {
        return true; // Existe colisión de horarios
      }
    }
    return false; // Horario libre
  }

  @override
  void dispose() {
    _productAvailabilitySubscription?.cancel();
    _reservasRealtimeSubscription?.cancel();
    _reservationRepository.disposeProductRealtime();
    super.dispose();
  }
}
