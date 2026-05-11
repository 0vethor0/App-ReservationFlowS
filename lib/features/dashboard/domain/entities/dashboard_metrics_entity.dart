/// Dashboard metrics entity for dashboard domain.
///
/// Pure Dart class without external dependencies.
library;

class DashboardMetrics {
  const DashboardMetrics({
    this.reservationsToday = 0,
    this.availableEquipment = 0,
    this.totalEquipment = 0,
    this.inMaintenance = 0,
    this.inUseNow = 0,
    this.pendingRequests = 0,
    this.weeklyUtilization = const [],
  });

  final int reservationsToday;
  final int availableEquipment;
  final int totalEquipment;
  final int inMaintenance;
  final int inUseNow;
  final int pendingRequests;
  final List<double> weeklyUtilization;
}
