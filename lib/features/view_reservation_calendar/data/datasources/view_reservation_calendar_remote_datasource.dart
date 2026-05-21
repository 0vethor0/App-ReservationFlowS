import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/calendar_status_filter.dart';

class ViewReservationCalendarRemoteDataSource {
  ViewReservationCalendarRemoteDataSource(this.client);

  final SupabaseClient client;
  RealtimeChannel? _reservasChannel;
  StreamController<void>? _reservasController;

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    return client
        .from('productos')
        .select('id, nombre')
        .order('nombre', ascending: true);
  }

  Future<List<Map<String, dynamic>>> fetchReservationsForDate(
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return client
        .from('reservas')
        .select('*, productos(*), perfiles(*)')
        .gte('hora_inicio', startOfDay.toIso8601String())
        .lt('hora_inicio', endOfDay.toIso8601String())
        .order('hora_inicio', ascending: true);
  }

  Future<List<Map<String, dynamic>>> fetchCalendarReservations({
    String? productId,
    required CalendarStatusFilter statusFilter,
  }) async {
    final rangeStart = DateTime.now().subtract(const Duration(days: 90));
    final rangeEnd = DateTime.now().add(const Duration(days: 180));

    var query = client
        .from('reservas')
        .select('*, productos(*)')
        .eq('estado_reserva', statusFilter.dbValue)
        .gte('hora_fin', rangeStart.toIso8601String())
        .lte('hora_inicio', rangeEnd.toIso8601String());

    if (productId != null) {
      query = query.eq('id_producto', productId);
    }

    return query.order('hora_inicio', ascending: true);
  }

  Stream<void> watchReservationsChanges() {
    _reservasController ??= StreamController<void>.broadcast();

    Future<void> emit() async {
      if (!(_reservasController?.isClosed ?? true)) {
        _reservasController!.add(null);
      }
    }

    _reservasChannel ??= client.channel('calendar_reservas_changes')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'reservas',
        callback: (payload) {
          debugPrint(
            '[CalendarDataSource] reservas ${payload.eventType}',
          );
          emit();
        },
      )
      ..subscribe();

    return _reservasController!.stream;
  }

  void disposeRealtime() {
    if (_reservasChannel != null) {
      client.removeChannel(_reservasChannel!);
      _reservasChannel = null;
    }
    _reservasController?.close();
    _reservasController = null;
  }
}
