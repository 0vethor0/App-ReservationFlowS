/// Data source for reservation operations.
///
/// Handles all Supabase reservation-related calls.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationRemoteDataSource {
  ReservationRemoteDataSource(this.client);

  final SupabaseClient client;
  RealtimeChannel? _productosChannel;
  StreamController<void>? _productosController;

  /// Load all videobeams (any status) for the reservation UI.
  Future<List<Map<String, dynamic>>> loadAllVideobeams() async {
    return client.from('productos').select('*, estados_producto(nombre)');
  }

  /// Load available videobeams from productos table
  Future<List<Map<String, dynamic>>> loadVideobeams() async {
    return client
        .from('productos')
        .select('*, estados_producto(nombre)')
        .eq('id_estado', 1);
  }

  /// Realtime stream fired when product availability changes in DB.
  Stream<void> watchProductAvailability() {
    _productosController ??= StreamController<void>.broadcast();

    _productosChannel ??= client.channel('productos_availability')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'productos',
        callback: (payload) {
          debugPrint('[ReservationDataSource] productos ${payload.eventType}');
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

  /// Fetch reservations for a specific date
  Future<List<Map<String, dynamic>>> fetchReservations(DateTime date) async {
    final dateStr = date.toIso8601String().split('T').first;

    return client.from('reservas').select().eq('fecha', dateStr);
  }

  Future<List<Map<String, dynamic>>> fetchApprovedReservations() async {
    return client
        .from('reservas')
        .select('*, productos(*)')
        .eq('estado_reserva', 'aprobada')
        .order('hora_inicio', ascending: true);
  }

  Future<List<Map<String, dynamic>>> fetchApprovedReservationsForProductOnDate({
    required String productId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return client
        .from('reservas')
        .select('*')
        .eq('id_producto', productId)
        .eq('estado_reserva', 'aprobada')
        .gte('hora_inicio', startOfDay.toIso8601String())
        .lt('hora_inicio', endOfDay.toIso8601String());
  }

  Future<String> getProfileIdByEmail(String email) async {
    final profileData = await client
        .from('perfiles')
        .select('id')
        .eq('correo', email)
        .single();

    return profileData['id'] as String;
  }

  Future<void> createReservationViaRpc({
    required String userId,
    required String productId,
    required DateTime start,
    required DateTime end,
    String? notes,
  }) async {
    await client.rpc(
      'intentar_reservar',
      params: {
        'p_usuario_id': userId,
        'p_producto_id': productId,
        'p_inicio': start.toUtc().toIso8601String(),
        'p_fin': end.toUtc().toIso8601String(),
        'p_notas': notes,
      },
    );
  }

  Future<Map<String, dynamic>> createMultipleReservationsViaRpc({
    required String userId,
    required String productId,
    required List<Map<String, dynamic>> dates,
    String? globalNotes,
  }) async {
    final params = {
      'p_usuario_id': userId,
      'p_producto_id': productId,
      'p_reservas': dates,
      'p_notas_globales': globalNotes,
    };
    debugPrint(
      '[ReservationRemoteDataSource] Llamando RPC intentar_reservas_multiples con params: $params',
    );

    final response = await client.rpc(
      'intentar_reservas_multiples',
      params: params,
    );

    debugPrint('[ReservationRemoteDataSource] Respuesta RPC: $response');

    // Asumimos que la respuesta es un Map, pero client.rpc puede devolver otras cosas según la función.
    // Si la función devuelve jsonb, debería ser un Map o List.
    if (response is Map<String, dynamic>) {
      return response;
    }
    return {'success': false, 'message': 'Respuesta inesperada: $response'};
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

  Future<void> deleteReservation(String reservationId) async {
    await client.from('reservas').delete().eq('id', reservationId);
  }

  /// Get user's reservations
  Future<List<Map<String, dynamic>>> getUserReservations(String userId) async {
    return client.from('reservas').select().eq('usuario_id', userId);
  }
}
