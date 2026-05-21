import 'package:flutter/material.dart';
import '../../features/view_reservation_calendar/domain/repositories/view_reservation_calendar_repository.dart';
import '../../features/reservations/domain/entities/reservation_entity.dart';

class ViewReservationCalendarProvider extends ChangeNotifier {
  ViewReservationCalendarProvider(this._repository) {
    loadReservations();
  }

  final ViewReservationCalendarRepository _repository;

  DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'Aprobadas';
  List<ReservationEntity> _reservations = [];
  bool _isLoading = false;
  String? _error;

  DateTime get selectedDate => _selectedDate;
  String get selectedFilter => _selectedFilter;
  List<ReservationEntity> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Returns the reservations filtered by the current selected status filter
  List<ReservationEntity> get filteredReservations {
    return _reservations.where((r) {
      switch (_selectedFilter) {
        case 'Aprobadas':
          return r.status == ReservationStatus.approved;
        case 'En curso':
          return r.status == ReservationStatus.inProgress;
        case 'Finalizadas':
          return r.status == ReservationStatus.completed;
        default:
          return true;
      }
    }).toList();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
    loadReservations();
  }

  void selectFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void previousDate() {
    selectDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  void nextDate() {
    selectDate(_selectedDate.add(const Duration(days: 1)));
  }

  Future<void> loadReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reservations = await _repository.fetchReservationsForDate(_selectedDate);
    } catch (e) {
      _error = 'Error al cargar las reservaciones: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
