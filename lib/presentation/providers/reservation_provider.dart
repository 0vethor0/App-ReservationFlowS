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
      // Filtramos para obtener solo los productos con id_estado = 1 (disponible)
      final data = await _supabase
          .from('productos')
          .select('*, estados_producto(nombre)')
          .eq('id_estado', 1);
          
      _videobeams = data.map((item) {
        return VideobeamEntity(
          id: item['id'].toString(),
          name: item['nombre'] as String? ?? 'Videobeam',
          brand: item['marca'] as String? ?? '',
          model: item['modelo'] as String? ?? '',
          location: item['ubicacion'] as String? ?? '',
          status: VideobeamStatus.available, // Solo mostramos los disponibles
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
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _startTime!.hour, _startTime!.minute
      );
      
      final endDateTime = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _endTime!.hour, _endTime!.minute
      );

      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // 1. Localizar al usuario en la tabla 'perfiles' para obtener su ID interno
      final profileData = await _supabase
          .from('perfiles')
          .select('id')
          .eq('correo', user.email!)
          .single();
      
      final profileId = profileData['id'];

      debugPrint('Confirmando reserva: id_producto=${_selectedVideobeam!.id}, id_usuario=$profileId');

      await _supabase.from('reservas').insert({
        'id_usuario': profileId,
        'id_producto': _selectedVideobeam!.id,
        'hora_inicio': startDateTime.toIso8601String(),
        'hora_fin': endDateTime.toIso8601String(),
        'estado_reserva': 'pendiente',
        'notas': _notes,
      });

      debugPrint('Reserva insertada con éxito');


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
