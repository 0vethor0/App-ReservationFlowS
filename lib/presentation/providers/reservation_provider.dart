/// Provider de reservaciones.
library;
import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  ReservationProvider() {
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

  List<VideobeamEntity> get videobeams => _videobeams;
  List<dynamic> get reservations => _reservations;
  VideobeamEntity? get selectedVideobeam => _selectedVideobeam;
  DateTime get selectedDate => _selectedDate;
  TimeOfDay? get startTime => _startTime;
  TimeOfDay? get endTime => _endTime;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadVideobeams() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase.from('productos').select();
      _videobeams = data.map((item) {
        return VideobeamEntity(
          id: item['id'].toString(),
          name: item['nombre'] as String? ?? 'Videobeam',
          brand: item['marca'] as String? ?? '',
          model: item['modelo'] as String? ?? '',
          location: item['ubicacion'] as String? ?? '',
          status: (item['estado'] == 'disponible')
              ? VideobeamStatus.available
              : (item['estado'] == 'en_uso' ? VideobeamStatus.inUse : VideobeamStatus.maintenance),
        );
      }).toList();
      await fetchReservations();
    } catch (e) {
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
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _startTime!.hour, _startTime!.minute
      );
      
      final endDateTime = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _endTime!.hour, _endTime!.minute
      );

      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      await _supabase.from('reservas').insert({
        'perfil_id': user.id,
        'producto_id': int.parse(_selectedVideobeam!.id),
        'hora_inicio': startDateTime.toIso8601String(),
        'hora_fin': endDateTime.toIso8601String(),
        'estado_reserva': 'pendiente',
      });

      _isLoading = false;
      _error = null;
      await fetchReservations();
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Error confirmando reserva: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchReservations() async {
    try {
      final data = await _supabase.from('reservas').select('*, productos(*)');
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
    _error = null;
    notifyListeners();
  }
}
