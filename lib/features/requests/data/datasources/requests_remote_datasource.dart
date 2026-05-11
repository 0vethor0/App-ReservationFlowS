/// Data source for requests operations.
///
/// Handles all Supabase requests-related calls.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

class RequestsRemoteDataSource {
  final SupabaseClient client;

  RequestsRemoteDataSource(this.client);

  /// Load all pending requests
  Future<List<Map<String, dynamic>>> loadPendingRequests() async {
    return await client.from('reservas').select().eq('estado', 'pending');
  }

  /// Load all requests
  Future<List<Map<String, dynamic>>> loadAllRequests() async {
    return await client.from('reservas').select();
  }

  /// Update request status
  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    await client
        .from('reservas')
        .update({'estado': status})
        .eq('id', requestId);
  }

  /// Mark request as read = marcar solicitud como leida
  Future<void> markAsRead(String requestId) async {
    await client.from('reservas').update({'leido': true}).eq('id', requestId);
  }
}
