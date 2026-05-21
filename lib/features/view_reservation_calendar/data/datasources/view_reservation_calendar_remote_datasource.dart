import 'package:supabase_flutter/supabase_flutter.dart';

class ViewReservationCalendarRemoteDataSource {
  ViewReservationCalendarRemoteDataSource(this.client);

  final SupabaseClient client;

  /// Fetches all reservations for a specific date, including products and user profiles
  Future<List<Map<String, dynamic>>> fetchReservationsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return client
        .from('reservas')
        .select('*, productos(*), perfiles(*)')
        .gte('hora_inicio', startOfDay.toIso8601String())
        .lt('hora_inicio', endOfDay.toIso8601String())
        .order('hora_inicio', ascending: true);
  }
}
