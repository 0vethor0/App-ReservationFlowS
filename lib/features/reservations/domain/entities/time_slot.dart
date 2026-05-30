library;

class TimeSlot {
  final DateTime start;
  final DateTime end;

  TimeSlot({required this.start, required this.end});

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      // Forzamos la conversión a la hora local del dispositivo (.toLocal)
      start: DateTime.parse(map['hora_inicio']).toLocal(),
      end: DateTime.parse(map['hora_fin']).toLocal(),
    );
  }
}
