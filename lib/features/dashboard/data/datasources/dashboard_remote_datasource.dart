/// Data source for dashboard operations.
///
/// Handles all Supabase dashboard-related calls.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this.client);

  final SupabaseClient client;
  RealtimeChannel? _productosChannel;
  StreamController<void>? _productosController;

  /// Get all products for metrics calculation
  Future<List<Map<String, dynamic>>> getProducts() async {
    return client.from('productos').select();
  }

  /// Get reservations for date range
  Future<List<Map<String, dynamic>>> getReservationsInRange({
    required String startDate,
    required String endDate,
  }) async {
    return client
        .from('reservas')
        .select('*, productos(*), perfiles(*)')
        .gte('hora_inicio', startDate)
        .lte('hora_inicio', endDate);
  }

  /// Get my reservations for a date
  Future<List<Map<String, dynamic>>> getMyReservations({
    required String email,
    required String startDate,
    required String endDate,
  }) async {
    final profileData = await client
        .from('perfiles')
        .select('id')
        .eq('correo', email)
        .single();
    final profileId = profileData['id'];

    return client
        .from('reservas')
        .select('*, productos(*), perfiles(*)')
        .eq('id_usuario', profileId)
        .gte('hora_inicio', startDate)
        .lt('hora_inicio', endDate)
        .order('hora_inicio', ascending: true);
  }

  /// Get today's reservations count
  Future<int> getTodayReservationsCount() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final data = await client
        .from('reservas')
        .select('id')
        .gte('hora_inicio', startOfToday.toIso8601String())
        .lte('hora_inicio', endOfToday.toIso8601String());

    return data.length;
  }

  /// Get pending requests count
  Future<int> getPendingRequestsCount() async {
    final data = await client
        .from('reservas')
        .select('id')
        .eq('estado_reserva', 'pendiente');

    return data.length;
  }

  /// Subscribe to realtime changes on reservas table
  Stream<List<Map<String, dynamic>>> subscribeToReservasRealtime() {
    return client
        .from('reservas')
        .stream(primaryKey: ['id'])
        .order('hora_inicio', ascending: true);
  }

  /// Update reservation status
  Future<void> updateReservationStatus(String id, String status) async {
    await client
        .from('reservas')
        .update({'estado_reserva': status})
        .eq('id', id);
  }

  /// Emits when product availability changes (cron, trigger o admin).
  Stream<void> watchProductAvailability() {
    _productosController ??= StreamController<void>.broadcast();

    _productosChannel ??= client.channel('dashboard_productos_availability')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'productos',
        callback: (payload) {
          debugPrint('[DashboardDataSource] productos ${payload.eventType}');
          if (!(_productosController?.isClosed ?? true)) {
            _productosController!.add(null);
          }
        },
      )
      ..subscribe();

    return _productosController!.stream;
  }

  void disposeProductRealtime() {
    if (_productosChannel != null) {
      client.removeChannel(_productosChannel!);
      _productosChannel = null;
    }
    _productosController?.close();
    _productosController = null;
  }
}
