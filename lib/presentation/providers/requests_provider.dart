/// Provider de solicitudes de reservación.
/// Este provider se encarga de cargar las solicitudes de reservación y
/// mostrarlas en la interfaz de usuario.
/// También se encarga de aprobar y rechazar las solicitudes de reservación.
/// También se encarga de filtrar las solicitudes de reservación por estado.

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
            r.videobeamName.toLowerCase().contains(query);
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
      // Cálculo de la semana actual (Lunes a Domingo)
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final start = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );
      final end = start.add(const Duration(days: 7));

      final data = await _supabase
          .from('reservas')
          .select('*, productos(*), perfiles(*)')
          .gte('hora_inicio', start.toIso8601String())
          .lt('hora_inicio', end.toIso8601String())
          .order('hora_inicio', ascending: true);

      debugPrint('Requests: Loading ${data.length} reservations for the week');

      _allRequests = data.map((r) {
        // Safe extraction with null checks
        final productosData = r['productos'];
        final perfilesData = r['perfiles'];

        final p = productosData is Map<String, dynamic>
            ? productosData
            : <String, dynamic>{};
        final u = perfilesData is Map<String, dynamic>
            ? perfilesData
            : <String, dynamic>{};

        return ReservationEntity(
          id: r['id']?.toString() ?? 'unknown',
          userId: u['id']?.toString() ?? 'unknown',
          userName:
              '${u['primer_nombre'] ?? 'Usuario'} ${u['primer_apellido'] ?? ''}',
          videobeamId: p['id']?.toString() ?? 'unknown',
          videobeamName: p['nombre'] as String? ?? 'Videobeam',
          date: r['hora_inicio'] != null
              ? DateTime.parse(r['hora_inicio'])
              : DateTime.now(),
          startTime: r['hora_inicio'] != null && r['hora_inicio'].length > 16
              ? r['hora_inicio'].substring(11, 16)
              : '00:00',
          endTime: r['hora_fin'] != null && r['hora_fin'].length > 16
              ? r['hora_fin'].substring(11, 16)
              : '00:00',
          status: _mapStatus(r['estado_reserva']),
          department:
              u['especialidad'] as String? ?? u['carrera'] as String? ?? '',
          priority: RequestPriority.normal,
          userAvatarUrl: u['foto_url'] as String?,
          notes: r['notas'] as String?,
        );
      }).toList();

      debugPrint(
        'Requests: Successfully loaded ${_allRequests.length} reservations',
      );
    } catch (e, stack) {
      debugPrint('Error loading requests: $e');
      debugPrint('Stack trace: $stack');
    }

    _isLoading = false;
    notifyListeners();
  }

  ReservationStatus _mapStatus(String? status) {
    if (status == null) return ReservationStatus.pending;
    switch (status.toLowerCase()) {
      case 'aprobada':
      case 'aprobado':
        return ReservationStatus.approved;
      case 'rechazada':
      case 'rechazado':
      case 'desaprobado':
        return ReservationStatus.rejected;
      case 'finalizada':
      case 'completado':
        return ReservationStatus.completed;
      case 'cancelado':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.pending;
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
      // Usamos 'aprobada' que es el valor correcto del enum en la DB
      await _supabase
          .from('reservas')
          .update({'estado_reserva': 'aprobada'})
          .eq('id', id);
      await loadRequests();
    } catch (e) {
      debugPrint('Error approving request: $e');
    }
  }

  Future<void> rejectRequest(String id) async {
    try {
      // Usamos 'rechazada' que es el valor correcto del enum en la DB
      await _supabase
          .from('reservas')
          .update({'estado_reserva': 'rechazada'})
          .eq('id', id);
      await loadRequests();
    } catch (e) {
      debugPrint('Error rejecting request: $e');
    }
  }
}
