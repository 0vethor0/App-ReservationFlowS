/// Status filter for the reservation calendar.
library;

enum CalendarStatusFilter { approved, inProgress, completed }

extension CalendarStatusFilterX on CalendarStatusFilter {
  String get label {
    switch (this) {
      case CalendarStatusFilter.approved:
        return 'Aprobadas';
      case CalendarStatusFilter.inProgress:
        return 'En curso';
      case CalendarStatusFilter.completed:
        return 'Finalizadas';
    }
  }

  String get dbValue {
    switch (this) {
      case CalendarStatusFilter.approved:
        return 'aprobada';
      case CalendarStatusFilter.inProgress:
        return 'en_curso';
      case CalendarStatusFilter.completed:
        return 'finalizada';
    }
  }
}
