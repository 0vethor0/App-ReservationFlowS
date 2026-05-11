/// Use case for loading dashboard metrics.
library;

import '../repositories/dashboard_repository.dart';
import '../entities/dashboard_metrics_entity.dart';

class LoadDashboardMetricsUseCase {
  final DashboardRepository repository;

  LoadDashboardMetricsUseCase(this.repository);

  Future<DashboardMetrics> call() {
    return repository.loadDashboardMetrics();
  }
}
