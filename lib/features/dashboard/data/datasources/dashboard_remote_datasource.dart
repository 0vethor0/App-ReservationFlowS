/// Data source for dashboard operations.
///
/// Handles all Supabase dashboard-related calls.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRemoteDataSource {
  final SupabaseClient client;

  DashboardRemoteDataSource(this.client);

  /// Get all products for metrics calculation
  Future<List<Map<String, dynamic>>> getProducts() async {
    return await client.from('productos').select();
  }

  /// Get reservations for date range
  Future<List<Map<String, dynamic>>> getReservationsInRange({
    required String startDate,
    required String endDate,
  }) async {
    return await client
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
  /// obtener el numero de solicitudes pendientes
  Future<int> getPendingRequestsCount() async {
    final data = await client.from('reservas').select().eq('estado', 'pending');

    return data.length;
  }
}
