library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../features/requests/domain/repositories/requests_repository.dart';
import '../../features/reservations/domain/entities/reservation_entity.dart';

class RequestsProvider extends ChangeNotifier {
  final RequestsRepository _requestsRepository;

  RequestsProvider(this._requestsRepository) {
    loadRequests();
    _setupRealtimeSubscription();
  }

  List<ReservationEntity> _allRequests = [];
  String _activeFilter = 'Pendientes';
  String _searchQuery = '';
  bool _isLoading = true;
  StreamSubscription? _realtimeSubscription;

  List<ReservationEntity> get filteredRequests {
    var filtered = _allRequests.where((r) {
      switch (_activeFilter) {
        case 'Pendientes':
          return r.status == ReservationStatus.pending;
        case 'Aprobadas':
          return r.status == ReservationStatus.approved;
        case 'Rechazadas':
          return r.status == ReservationStatus.rejected;
        case 'En curso':
          return r.status == ReservationStatus.inProgress;
        case 'Finalizadas':
          return r.status == ReservationStatus.completed;
        case 'Canceladas':
          return r.status == ReservationStatus.cancelled;
        default:
          return true;
      }
    }).toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((r) {
        return r.userName.toLowerCase().contains(query) ||
            r.videobeamName.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  int get pendingCount =>
      _allRequests.where((r) => r.status == ReservationStatus.pending).length;
  String get activeFilter => _activeFilter;
  bool get isLoading => _isLoading;

  void _setupRealtimeSubscription() {
    debugPrint('[RequestsProvider] Setting up real-time subscription');

    _realtimeSubscription = _requestsRepository.streamAllRequests().listen(
      (updatedRequests) {
        debugPrint('[RequestsProvider] Received real-time update with ${updatedRequests.length} requests');

        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        final end = start.add(const Duration(days: 7));

        final filteredRequests = updatedRequests.where((r) {
          final isInCurrentWeek = r.date.isAtSameMomentAs(start) ||
              (r.date.isAfter(start) && r.date.isBefore(end));

          final isFutureRequest = r.date.isAtSameMomentAs(now) || r.date.isAfter(now) ;

          return isInCurrentWeek || isFutureRequest;
        }).toList();

        _allRequests = filteredRequests;
        
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('[RequestsProvider] Real-time subscription error: $error');
      },
    );
  }

  Future<void> loadRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('[RequestsProvider] Loading requests from repository...');
      _allRequests = await _requestsRepository.loadAllRequests();
      debugPrint('[RequestsProvider] Successfully loaded ${_allRequests.length} requests');
    } catch (e, stack) {
      debugPrint('[RequestsProvider] Error loading requests: $e');
      debugPrint('[RequestsProvider] Stack trace: $stack');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> approveRequest(String id) async {
    try {
      debugPrint('[RequestsProvider] Approving request: $id');
      final success = await _requestsRepository.updateRequestStatus(
        requestId: id,
        status: ReservationStatus.approved,
      );

      if (success) {
        debugPrint('[RequestsProvider] Request approved successfully');
      }
    } catch (e) {
      debugPrint('[RequestsProvider] Error approving request: $e');
    }
  }

  Future<void> rejectRequest(String id) async {
    try {
      debugPrint('[RequestsProvider] Rejecting request: $id');
      final success = await _requestsRepository.updateRequestStatus(
        requestId: id,
        status: ReservationStatus.rejected,
      );

      if (success) {
        debugPrint('[RequestsProvider] Request rejected successfully');
      }
    } catch (e) {
      debugPrint('[RequestsProvider] Error rejecting request: $e');
    }
  }

  Future<void> cancelRequest(String id) async {
    try {
      debugPrint('[RequestsProvider] Cancelling request: $id');
      final success = await _requestsRepository.updateRequestStatus(
        requestId: id,
        status: ReservationStatus.cancelled,
      );

      if (success) {
        debugPrint('[RequestsProvider] Request cancelled successfully');
      }
    } catch (e) {
      debugPrint('[RequestsProvider] Error cancelling request: $e');
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    debugPrint('[RequestsProvider] Disposed and cancelled real-time subscription');
    super.dispose();
  }
}