/// Provider de reservaciones.
/// Refactored to use Clean Architecture repositories.
library;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/reservations/domain/repositories/reservation_repository.dart';
import '../../features/reservations/domain/entities/videobeam_entity.dart';

class ReservationProvider extends ChangeNotifier {
  // ignore: unused_field
  final ReservationRepository _reservationRepository;
  final SupabaseClient _supabase = Supabase.instance.client;

  ReservationProvider(this._reservationRepository) {
    _loadVideobeams();
  }

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
      debugPrint('Loading videobeams with all statuses...');
      final data = await _supabase
          .from('productos')
          .select('*, estados_producto(nombre)');

      debugPrint('Found ${data.length} total videobeams');

      _videobeams = data.map((item) {
        final idEstado = item['id_estado'] as int?;
        VideobeamStatus status;

        switch (idEstado) {
          case 1:
            status = VideobeamStatus.available;
            break;
          case 2:
            status = VideobeamStatus.inUse;
            break;
          case 3:
          case 4:
            status = VideobeamStatus.maintenance;
            break;
          default:
            status = VideobeamStatus.available;
        }

        return VideobeamEntity(
          id: item['id']?.toString() ?? 'unknown',
          name: item['nombre'] as String? ?? 'Videobeam',
          brand: item['marca'] as String? ?? '',
          model: item['modelo'] as String? ?? '',
          status: status,
        );
      }).toList();

      debugPrint('Successfully loaded ${_videobeams.length} videobeams');
      await fetchReservations();
    } catch (e, stackTrace) {
      debugPrint('Error loading videobeams: $e');
      debugPrint('Stack trace: $stackTrace');
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

      // Usar rango de fechas en lugar de LIKE (que no funciona con timestamps)
      final startOfDay = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final existingReservations = await _supabase
          .from('reservas')
          .select('*')
          .eq('id_producto', _selectedVideobeam!.id)
          .eq('estado_reserva', 'aprobada')
          .gte('hora_inicio', startOfDay.toIso8601String())
          .lt('hora_inicio', endOfDay.toIso8601String());

      if (existingReservations.isNotEmpty) {
        final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
        final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

        for (final reservation in existingReservations) {
          final existingStart = DateTime.parse(
            reservation['hora_inicio'] as String,
          );
          final existingEnd = DateTime.parse(reservation['hora_fin'] as String);

          final existingStartMinutes =
              existingStart.hour * 60 + existingStart.minute;
          final existingEndMinutes = existingEnd.hour * 60 + existingEnd.minute;

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

      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final profileData = await _supabase
          .from('perfiles')
          .select('id')
          .eq('correo', user.email!)
          .single();

      final profileId = profileData['id'];

      debugPrint(
        'Confirmando reserva via RPC: id_producto=${_selectedVideobeam!.id}, id_usuario=$profileId',
      );
      debugPrint('Horario: $startDateTime - $endDateTime');

      // Usar la función RPC con la firma correcta:
      // intentar_reservar(p_fin, p_inicio, p_producto_id, p_usuario_id)
      await _supabase.rpc(
        'intentar_reservar',
        params: {
          'p_usuario_id': profileId,
          'p_producto_id': _selectedVideobeam!.id,
          'p_inicio': startDateTime.toIso8601String(),
          'p_fin': endDateTime.toIso8601String(),
        },
      );

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
      // Filtramos solo las reservaciones con estado 'aprobada'
      final data = await _supabase
          .from('reservas')
          .select('*, productos(*)')
          .eq('estado_reserva', 'aprobada')
          .order('hora_inicio', ascending: true);
      _reservations = data;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching reservations: $e');
    }
  }

  Future<bool> deleteReservation(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _supabase.from('reservas').delete().eq('id', id);
      await fetchReservations();
      _isLoading = false;
      notifyListeners();
      return true;
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
}
