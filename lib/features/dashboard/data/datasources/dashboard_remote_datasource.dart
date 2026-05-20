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
        .select()
        .gte('fecha', startDate)
        .lte('fecha', endDate);
  }

  /// Get today's reservations count
  Future<int> getTodayReservationsCount() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final data = await client.from('reservas').select().eq('fecha', today);

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

  /// Emits when product availability changes (cron, trigger o admin).
  Stream<void> watchProductAvailability() {
    _productosController ??= StreamController<void>.broadcast();

    _productosChannel ??= client.channel('dashboard_productos_availability')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'productos',
        callback: (payload) {
          debugPrint(
            '[DashboardDataSource] productos ${payload.eventType}',
          );
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
