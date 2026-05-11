/// Data source for reservation operations.
///
/// Handles all Supabase reservation-related calls.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationRemoteDataSource {
  final SupabaseClient client;

  ReservationRemoteDataSource(this.client);

  /// Load available videobeams from productos table
  Future<List<Map<String, dynamic>>> loadVideobeams() async {
    final data = await client
        .from('productos')
        .select('*, estados_producto(nombre)')
        .eq('id_estado', 1);

    return data;
  }

  /// Fetch reservations for a specific date
  Future<List<Map<String, dynamic>>> fetchReservations(DateTime date) async {
    final dateStr = date.toIso8601String().split('T').first;

    final data = await client.from('reservas').select().eq('fecha', dateStr);

    return data;
  }

  /// Create a new reservation
  Future<void> createReservation(Map<String, dynamic> reservationData) async {
    await client.from('reservas').insert(reservationData);
  }

  /// Cancel a reservation
  Future<void> cancelReservation(String reservationId) async {
    await client
        .from('reservas')
        .update({'estado': 'cancelled'})
        .eq('id', reservationId);
  }

  /// Get user's reservations
  Future<List<Map<String, dynamic>>> getUserReservations(String userId) async {
    final data = await client
        .from('reservas')
        .select()
        .eq('usuario_id', userId);

    return data;
  }
}
