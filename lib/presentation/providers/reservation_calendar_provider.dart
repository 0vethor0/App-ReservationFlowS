/// Provider for the SfCalendar tab (product + status filters).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import '../../features/reservations/domain/entities/reservation_entity.dart';
import '../../features/view_reservation_calendar/domain/entities/calendar_product_entity.dart';
import '../../features/view_reservation_calendar/domain/entities/calendar_status_filter.dart';
import '../../features/view_reservation_calendar/domain/repositories/view_reservation_calendar_repository.dart';

class ReservationCalendarProvider extends ChangeNotifier {
  ReservationCalendarProvider(this._repository) {
    _init();
  }

  final ViewReservationCalendarRepository _repository;
  StreamSubscription<void>? _realtimeSubscription;

  List<CalendarProductEntity> _products = [];
  List<ReservationEntity> _reservations = [];
  String? _selectedProductId;
  CalendarStatusFilter _statusFilter = CalendarStatusFilter.approved;
  bool _isLoading = false;
  String? _error;

  List<CalendarProductEntity> get products => _products;
  List<ReservationEntity> get reservations => _reservations;
  String? get selectedProductId => _selectedProductId;
  CalendarProductEntity? get selectedProduct {
    if (_selectedProductId == null) return null;
    for (final p in _products) {
      if (p.id == _selectedProductId) return p;
    }
    return null;
  }

  CalendarStatusFilter get statusFilter => _statusFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _init() async {
    await loadProducts();
    await loadReservations();
    _realtimeSubscription = _repository.watchReservationsChanges().listen((_) {
      loadReservations();
    });
  }

  Future<void> loadProducts() async {
    try {
      _products = await _repository.fetchProducts();
      if (_selectedProductId != null &&
          !_products.any((p) => p.id == _selectedProductId)) {
        _selectedProductId = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[ReservationCalendarProvider] loadProducts: $e');
    }
  }

  Future<void> loadReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reservations = await _repository.fetchCalendarReservations(
        productId: _selectedProductId,
        statusFilter: _statusFilter,
      );
    } catch (e) {
      _error = 'Error al cargar reservaciones: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectProduct(String? productId) {
    if (_selectedProductId == productId) return;
    _selectedProductId = productId;
    notifyListeners();
    loadReservations();
  }

  void selectStatusFilter(CalendarStatusFilter filter) {
    if (_statusFilter == filter) return;
    _statusFilter = filter;
    notifyListeners();
    loadReservations();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _repository.disposeRealtime();
    super.dispose();
  }
}
