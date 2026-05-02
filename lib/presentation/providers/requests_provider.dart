/// Provider de solicitudes de reservación.
library;
import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

class RequestsProvider extends ChangeNotifier {
  RequestsProvider() {
    loadRequests();
  }

  List<ReservationEntity> _allRequests = [];
  String _activeFilter = 'Pendientes';
  String _searchQuery = '';
  bool _isLoading = true;

  List<ReservationEntity> get filteredRequests {
    var filtered = _allRequests.where((r) {
      switch (_activeFilter) {
        case 'Pendientes':
          return r.status == ReservationStatus.pending;
        case 'Aprobadas':
          return r.status == ReservationStatus.approved;
        case 'Rechazadas':
          return r.status == ReservationStatus.rejected;
        default:
          return true;
      }
    }).toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((r) {
        return r.userName.toLowerCase().contains(query) ||
            r.videobeamName.toLowerCase().contains(query) ||
            r.location.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  int get pendingCount =>
      _allRequests.where((r) => r.status == ReservationStatus.pending).length;
  String get activeFilter => _activeFilter;
  bool get isLoading => _isLoading;

  Future<void> loadRequests() async {
    _isLoading = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 600));

    _allRequests = [
      ReservationEntity(
        id: 'r1',
        userId: 'u1',
        userName: 'Carlos Mendoza',
        videobeamId: 'v1',
        videobeamName: 'Epson Pro EX9220',
        location: 'Sala Juntas A',
        date: DateTime.now(),
        startTime: '09:30',
        endTime: '11:30',
        status: ReservationStatus.pending,
        department: 'Dpto. de Ventas',
        priority: RequestPriority.high,
      ),
      ReservationEntity(
        id: 'r2',
        userId: 'u2',
        userName: 'Ana Silva',
        videobeamId: 'v3',
        videobeamName: 'BenQ TH685P',
        location: 'Sala Capacitación',
        date: DateTime.now().add(const Duration(days: 1)),
        startTime: '14:00',
        endTime: '16:00',
        status: ReservationStatus.pending,
        department: 'Recursos Humanos',
        priority: RequestPriority.normal,
      ),
      ReservationEntity(
        id: 'r3',
        userId: 'u3',
        userName: 'María López',
        videobeamId: 'v2',
        videobeamName: 'Sony VPL-PHZ60',
        location: 'Auditorio Principal',
        date: DateTime.now().add(const Duration(days: 2)),
        startTime: '10:00',
        endTime: '12:00',
        status: ReservationStatus.pending,
        department: 'Marketing',
        priority: RequestPriority.normal,
      ),
      ReservationEntity(
        id: 'r4',
        userId: 'u4',
        userName: 'Pedro García',
        videobeamId: 'v4',
        videobeamName: 'ViewSonic PX701-4K',
        location: 'Sala Conferencias B',
        date: DateTime.now().subtract(const Duration(days: 1)),
        startTime: '15:00',
        endTime: '17:00',
        status: ReservationStatus.approved,
        department: 'Ingeniería',
        priority: RequestPriority.normal,
      ),
      ReservationEntity(
        id: 'r5',
        userId: 'u5',
        userName: 'Laura Martínez',
        videobeamId: 'v1',
        videobeamName: 'Epson Pro EX9220',
        location: 'Sala Juntas A',
        date: DateTime.now().subtract(const Duration(days: 2)),
        startTime: '08:00',
        endTime: '10:00',
        status: ReservationStatus.rejected,
        department: 'Finanzas',
        priority: RequestPriority.high,
      ),
    ];

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

  void approveRequest(String id) {
    final index = _allRequests.indexWhere((r) => r.id == id);
    if (index != -1) {
      final req = _allRequests[index];
      _allRequests[index] = ReservationEntity(
        id: req.id,
        userId: req.userId,
        userName: req.userName,
        videobeamId: req.videobeamId,
        videobeamName: req.videobeamName,
        location: req.location,
        date: req.date,
        startTime: req.startTime,
        endTime: req.endTime,
        status: ReservationStatus.approved,
        department: req.department,
        priority: req.priority,
        userAvatarUrl: req.userAvatarUrl,
      );
      notifyListeners();
    }
  }

  void rejectRequest(String id) {
    final index = _allRequests.indexWhere((r) => r.id == id);
    if (index != -1) {
      final req = _allRequests[index];
      _allRequests[index] = ReservationEntity(
        id: req.id,
        userId: req.userId,
        userName: req.userName,
        videobeamId: req.videobeamId,
        videobeamName: req.videobeamName,
        location: req.location,
        date: req.date,
        startTime: req.startTime,
        endTime: req.endTime,
        status: ReservationStatus.rejected,
        department: req.department,
        priority: req.priority,
        userAvatarUrl: req.userAvatarUrl,
      );
      notifyListeners();
    }
  }
}
