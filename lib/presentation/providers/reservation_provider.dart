library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/reservations/domain/repositories/reservation_repository.dart';
import '../../features/reservations/domain/entities/videobeam_entity.dart';

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
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
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

  @override
  void dispose() {
    _productAvailabilitySubscription?.cancel();
    _reservationRepository.disposeProductRealtime();
    super.dispose();
  }
}
