/// Provider de reservaciones.
import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

class ReservationProvider extends ChangeNotifier {
  ReservationProvider() {
    _loadVideobeams();
  }

  List<VideobeamEntity> _videobeams = [];
  VideobeamEntity? _selectedVideobeam;
  DateTime _selectedDate = DateTime.now();
  final Set<String> _selectedTimeSlots = {};
  bool _isLoading = false;
  String? _error;

  List<VideobeamEntity> get videobeams => _videobeams;
  VideobeamEntity? get selectedVideobeam => _selectedVideobeam;
  DateTime get selectedDate => _selectedDate;
  Set<String> get selectedTimeSlots => _selectedTimeSlots;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadVideobeams() async {
    _isLoading = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 500));

    _videobeams = const [
      VideobeamEntity(
        id: 'v1',
        name: 'Epson Pro EX9220',
        brand: 'Epson',
        model: 'EX9220',
        location: 'Sala de Juntas A',
        status: VideobeamStatus.available,
      ),
      VideobeamEntity(
        id: 'v2',
        name: 'Sony VPL-PHZ60',
        brand: 'Sony',
        model: 'VPL-PHZ60',
        location: 'Auditorio Principal',
        status: VideobeamStatus.available,
      ),
      VideobeamEntity(
        id: 'v3',
        name: 'BenQ TH685P',
        brand: 'BenQ',
        model: 'TH685P',
        location: 'Sala Capacitación',
        status: VideobeamStatus.inUse,
      ),
      VideobeamEntity(
        id: 'v4',
        name: 'ViewSonic PX701-4K',
        brand: 'ViewSonic',
        model: 'PX701-4K',
        location: 'Sala Conferencias B',
        status: VideobeamStatus.available,
      ),
      VideobeamEntity(
        id: 'v5',
        name: 'Optoma UHD38x',
        brand: 'Optoma',
        model: 'UHD38x',
        location: 'Sala Ejecutiva',
        status: VideobeamStatus.maintenance,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void selectVideobeam(VideobeamEntity videobeam) {
    _selectedVideobeam = videobeam;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedTimeSlots.clear();
    notifyListeners();
  }

  void toggleTimeSlot(String slot) {
    if (_selectedTimeSlots.contains(slot)) {
      _selectedTimeSlots.remove(slot);
    } else {
      _selectedTimeSlots.add(slot);
    }
    notifyListeners();
  }

  List<String> generateTimeSlots() {
    final slots = <String>[];
    for (int hour = 7; hour < 21; hour++) {
      for (int min = 0; min < 60; min += 15) {
        final h = hour.toString().padLeft(2, '0');
        final m = min.toString().padLeft(2, '0');
        slots.add('$h:$m');
      }
    }
    return slots;
  }

  Future<bool> confirmReservation() async {
    if (_selectedVideobeam == null || _selectedTimeSlots.isEmpty) {
      _error = 'Selecciona un equipo y al menos un horario';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(seconds: 1));

    _isLoading = false;
    _error = null;
    notifyListeners();
    return true;
  }

  void reset() {
    _selectedVideobeam = null;
    _selectedDate = DateTime.now();
    _selectedTimeSlots.clear();
    _error = null;
    notifyListeners();
  }
}
