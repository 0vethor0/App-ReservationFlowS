/// Dashboard Principal — métricas, gráfico de utilización, próximas reservas.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/neon_card.dart';
import '../../../domain/entities/entities.dart';

import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';

import '../reservation/reservation_screen.dart';
import '../requests/requests_screen.dart';

import 'components/dashboard_header.dart';
import 'components/metric_card.dart';
import 'components/utilization_chart.dart';
import 'components/upcoming_reservation_tile.dart';
import 'components/admin_action_buttons.dart';
import 'modals/products_management_modal.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userRole = auth.currentUser?.role;
    final isAdmin = userRole == UserRole.admin || userRole == UserRole.superAdmin;

    final screens = [
      const _DashboardBody(),
      const ReservationScreen(),
      if (isAdmin) const RequestsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined),
              label: AppStrings.dashboard,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 1
                    ? Icons.calendar_month
                    : Icons.calendar_month_outlined,
              ),
              label: AppStrings.reserve,
            ),
            if (isAdmin)
              BottomNavigationBarItem(
                icon: Icon(
                  _currentIndex == 2 ? Icons.mail : Icons.mail_outline,
                ),
                label: AppStrings.requests,
              ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.currentUser?.role == UserRole.admin ||
        auth.currentUser?.role == UserRole.superAdmin;

    return Consumer<DashboardProvider>(
      builder: (context, dash, _) {
        if (dash.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }

        final m = dash.metrics;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Header
                DashboardHeader(
                  user: auth.currentUser,
                  onSettingsTap: () => context.push('/profile'),
                  onLogoutTap: () async {
                    await auth.signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),

                // Title Section
                _SectionTitle(title: AppStrings.todaySummary),

                const SizedBox(height: 16),

                // Metric Cards Row 1
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        icon: Icons.calendar_today,
                        iconBg: AppColors.lightBlue,
                        value: '${m.reservationsToday}',
                        label: AppStrings.reservationsToday,
                        badge: '+2',
                        badgeColor: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        icon: Icons.devices,
                        iconBg: AppColors.lightBlue,
                        value: '${m.availableEquipment}',
                        label: AppStrings.availableEquipment,
                        suffix: ' ${AppStrings.available}',
                        topRight: AppStrings.totalEquipment,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Metric Cards Row 2 (Maintenance & In Use)
                _MaintenanceStatusCard(
                  inMaintenance: m.inMaintenance,
                  inUseNow: m.inUseNow,
                ),

                const SizedBox(height: 16),

                // Admin Action Buttons (only visible for admins)
                if (isAdmin)
                  AdminActionButtons(
                    onProductsTap: () => showMaterialModalBottomSheet(
                      context: context,
                      expand: true,
                      builder: (context) => const ProductsManagementModal(),
                    ),
                    onRequestsTap: () {},
                  ),

                const SizedBox(height: 28),

                // Utilization Chart
                UtilizationChart(data: m.weeklyUtilization),

                const SizedBox(height: 28),

                // Upcoming Reservations
                _UpcomingReservationsSection(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _MaintenanceStatusCard extends StatelessWidget {
  const _MaintenanceStatusCard({
    required this.inMaintenance,
    required this.inUseNow,
  });

  final int inMaintenance;
  final int inUseNow;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.build_outlined,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$inMaintenance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              AppStrings.inMaintenance,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.divider,
          ),
          const SizedBox(width: 16),
          Text(
            '$inUseNow',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            AppStrings.inUseNow,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingReservationsSection extends StatelessWidget {
  const _UpcomingReservationsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.upcomingReservations,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              AppStrings.viewAll,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer<ReservationProvider>(
          builder: (context, resProv, _) {
            if (resProv.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                ),
              );
            }
            if (resProv.reservations.isEmpty) {
              return Text(
                'No hay reservaciones',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              );
            }
            return Column(
              children: resProv.reservations
                  .take(3)
                  .map(
                    (r) => UpcomingReservationTile(reservation: r),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}