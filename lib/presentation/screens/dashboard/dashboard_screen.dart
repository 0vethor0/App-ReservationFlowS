/// Dashboard Principal — métricas, gráfico de utilización, próximas reservas.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../features/auth/domain/entities/user_entity.dart';

import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/reservation_calendar_provider.dart';
import '../../../features/view_reservation_calendar/domain/repositories/view_reservation_calendar_repository.dart';


import '../reservation/reservation_screen.dart';
import '../reservation/reservation_calendar_view.dart';
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

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  RealtimeChannel? _presenceChannel; // Ahora puede ser nula
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPresence();
    });
  }

  void _initPresence() {
    final auth = context.read<AuthProvider>();
    final isAdmin =
        auth.currentUser?.role == UserRole.admin ||
        auth.currentUser?.role == UserRole.superAdmin;

    if (!isAdmin) return;

    _presenceChannel = _supabase.channel('admin_presence');

    // Usamos el operador ?. para seguridad
    _presenceChannel?.subscribe((status, [error]) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        await _presenceChannel?.track({
          'status': 'online',
          'viewing': 'dashboard',
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final auth = context.read<AuthProvider>();
    final isAdmin =
        auth.currentUser?.role == UserRole.admin ||
        auth.currentUser?.role == UserRole.superAdmin;

    if (!isAdmin) return;

    if (state == AppLifecycleState.resumed) {
      _marcarComoLeido();
    }
  }

  Future<void> _marcarComoLeido() async {
    try {
      await _supabase
          .from('reservas')
          .update({'leido_por_admin': true})
          .eq('leido_por_admin', false);
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Solo intentamos removerlo si realmente fue inicializado
    if (_presenceChannel != null) {
      _supabase.removeChannel(_presenceChannel!);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userRole = auth.currentUser?.role;
    final isAdmin =
        userRole == UserRole.admin || userRole == UserRole.superAdmin;

    final screens = [
      const _DashboardBody(),
      const _CalendarioTab(),
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
                    ? Icons.date_range_rounded
                    : Icons.date_range_outlined,
              ),
              label: AppStrings.calendario,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 2
                    ? Icons.calendar_month
                    : Icons.calendar_month_outlined,
              ),
              label: AppStrings.reserve,
            ),
            if (isAdmin)
              BottomNavigationBarItem(
                icon: Icon(
                  _currentIndex == 3 ? Icons.mail : Icons.mail_outline,
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
    final isAdmin =
        auth.currentUser?.role == UserRole.admin ||
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
                const _SectionTitle(title: AppStrings.todaySummary),

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
                       ),
                     ),
                   ],
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
                const UtilizationChart(),

                const SizedBox(height: 28),

                // Upcoming Reservations
                const _UpcomingReservationsSection(),

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
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
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
        const Row(
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
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }
            if (resProv.reservations.isEmpty) {
              return const Text(
                'No hay reservaciones',
                style: TextStyle(color: AppColors.textSecondary),
              );
            }
            return Column(
              children: resProv.reservations
                  .take(3)
                  .map((r) => UpcomingReservationTile(reservation: r))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _CalendarioTab extends StatelessWidget {
  const _CalendarioTab();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReservationCalendarProvider(
        context.read<ViewReservationCalendarRepository>(),
      ),
      child: const ReservationCalendarView(showAppBar: false),
    );
  }
}
