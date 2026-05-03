/// Provider de solicitudes de reservación.
library;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/entities.dart';

class RequestsProvider extends ChangeNotifier {
  RequestsProvider() {
    loadRequests();
  }

  final SupabaseClient _supabase = Supabase.instance.client;

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

    try {
      final data = await _supabase
          .from('reservas')
          .select('*, productos(*), perfiles(*)');

      _allRequests = data.map((r) {
        final p = r['productos'] as Map<String, dynamic>;
        final u = r['perfiles'] as Map<String, dynamic>;
        return ReservationEntity(
          id: r['id'].toString(),
          userId: u['id'].toString(),
          userName: '${u['primer_nombre']} ${u['primer_apellido'] ?? ''}',
          videobeamId: p['id'].toString(),
          videobeamName: p['nombre'] as String,
          location: p['ubicacion'] as String,
          date: DateTime.parse(r['hora_inicio']),
          startTime: r['hora_inicio'].substring(11, 16),
          endTime: r['hora_fin'].substring(11, 16),
          status: _mapStatus(r['estado_reserva']),
          department: u['carrera'] as String? ?? '',
          priority: RequestPriority.normal,
          userAvatarUrl: u['foto_url'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading requests: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  ReservationStatus _mapStatus(String status) {
    switch (status) {
      case 'aprobado': return ReservationStatus.approved;
      case 'rechazado': return ReservationStatus.rejected;
      case 'completado': return ReservationStatus.completed;
      case 'cancelado': return ReservationStatus.cancelled;
      default: return ReservationStatus.pending;
    }
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
      await _supabase.from('reservas').update({'estado_reserva': 'aprobado'}).eq('id', id);
      await loadRequests();
    } catch (e) {
      debugPrint('Error approving request: $e');
    }
  }

  Future<void> rejectRequest(String id) async {
    try {
      await _supabase.from('reservas').update({'estado_reserva': 'rechazado'}).eq('id', id);
      await loadRequests();
    } catch (e) {
      debugPrint('Error rejecting request: $e');
    }
  }
}
