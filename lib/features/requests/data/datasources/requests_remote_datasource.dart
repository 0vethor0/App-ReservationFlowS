library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestsRemoteDataSource {
  final SupabaseClient client;
  RealtimeChannel? _allRequestsChannel;
  RealtimeChannel? _pendingRequestsChannel;
  StreamController<List<Map<String, dynamic>>>? _allRequestsController;
  StreamController<List<Map<String, dynamic>>>? _pendingRequestsController;

  RequestsRemoteDataSource(this.client);

  Future<List<Map<String, dynamic>>> loadPendingRequests() async {
    debugPrint('[RequestsDataSource] Loading pending requests...');
    final response = await client
        .from('reservas')
        .select('*, productos(*), perfiles(*)')
        .eq('estado_reserva', 'pendiente')
        .order('hora_inicio', ascending: true);

    debugPrint('[RequestsDataSource] Found ${response.length} pending requests');
    return response;
  }

  Future<List<Map<String, dynamic>>> loadAllRequests() async {
    debugPrint('[RequestsDataSource] Loading current week + future pending requests...');

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endOfWeek = start.add(const Duration(days: 7));

    final currentWeekRequests = await client
        .from('reservas')
        .select('*, productos(*), perfiles(*)')
        .gte('hora_inicio', start.toIso8601String())
        .lt('hora_inicio', endOfWeek.toIso8601String())
        .order('hora_inicio', ascending: true);

    final futureRequests = await client
        .from('reservas')
        .select('*, productos(*), perfiles(*)')
        .gte('hora_inicio', startOfToday.toIso8601String())
        .order('hora_inicio', ascending: true);

    final allRequests = <Map<String, dynamic>>[];
    final seenIds = <String>{};

    for (final request in [...currentWeekRequests, ...futureRequests]) {
      final id = request['id']?.toString();
      if (id != null && !seenIds.contains(id)) {
        allRequests.add(request);
        seenIds.add(id);
      }
    }

    allRequests.sort((a, b) {
      final dateA = DateTime.parse(a['hora_inicio']);
      final dateB = DateTime.parse(b['hora_inicio']);
      return dateA.compareTo(dateB);
    });

    debugPrint('[RequestsDataSource] Found ${allRequests.length} requests (current week + future)');
    return allRequests;
  }

  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    debugPrint('[RequestsDataSource] Updating request $requestId status to: $status');

    final reservationData = await client
        .from('reservas')
        .select('id_producto')
        .eq('id', requestId)
        .single();

    final productId = reservationData['id_producto'];

    await client
        .from('reservas')
        .update({'estado_reserva': status})
        .eq('id', requestId);

    // Estado del producto: lo gestiona el trigger trg_reserva_estado_producto en Supabase.
    // Realtime en tabla productos notifica a ReservationProvider y DashboardProvider.
    if (productId != null) {
      debugPrint(
        '[RequestsDataSource] Reserva $requestId → $status; producto $productId vía trigger BD',
      );
    }
  }

  Future<void> markAsRead(String requestId) async {
    debugPrint('[RequestsDataSource] Marking request $requestId as read');
    await client
        .from('reservas')
        .update({'leido_por_admin': true})
        .eq('id', requestId);
  }

  Stream<List<Map<String, dynamic>>> streamAllRequests() {
    debugPrint('[RequestsDataSource] Setting up real-time stream for all requests');

    _allRequestsController = StreamController<List<Map<String, dynamic>>>.broadcast();

    loadAllRequests().then((data) {
      if (!_allRequestsController!.isClosed) {
        _allRequestsController!.add(data);
      }
    });

    _allRequestsChannel = client.channel('requests_changes')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'reservas',
        callback: (payload) {
          debugPrint('[RequestsDataSource] Database change detected, reloading...');
          loadAllRequests().then((data) {
            if (!_allRequestsController!.isClosed) {
              _allRequestsController!.add(data);
            }
          });
        },
      )
      ..subscribe();

    return _allRequestsController!.stream;
  }

  Stream<List<Map<String, dynamic>>> streamPendingRequests() {
    debugPrint('[RequestsDataSource] Setting up real-time stream for pending requests');

    _pendingRequestsController = StreamController<List<Map<String, dynamic>>>.broadcast();

    loadPendingRequests().then((data) {
      if (!_pendingRequestsController!.isClosed) {
        _pendingRequestsController!.add(data);
      }
    });

    _pendingRequestsChannel = client.channel('pending_requests_changes')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'reservas',
        callback: (payload) {
          debugPrint('[RequestsDataSource] Database change detected, reloading pending...');
          loadPendingRequests().then((data) {
            if (!_pendingRequestsController!.isClosed) {
              _pendingRequestsController!.add(data);
            }
          });
        },
      )
      ..subscribe();

    return _pendingRequestsController!.stream;
  }

  void dispose() {
    debugPrint('[RequestsDataSource] Disposing and cleaning up channels');
    if (_allRequestsChannel != null) {
      client.removeChannel(_allRequestsChannel!);
      _allRequestsChannel = null;
    }
    if (_pendingRequestsChannel != null) {
      client.removeChannel(_pendingRequestsChannel!);
      _pendingRequestsChannel = null;
    }
    _allRequestsController?.close();
    _pendingRequestsController?.close();
  }
}