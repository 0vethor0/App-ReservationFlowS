/// Gestión de Solicitudes — lista con Dismissible, filtros y búsqueda.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/neon_card.dart';
import '../../providers/requests_provider.dart';
import '../../../domain/entities/entities.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestsProvider>(
      builder: (context, prov, _) {
        return SafeArea(
          child: Column(children: [
            const SizedBox(height: 16),
            // Tab bar: Notificaciones / Solicitudes
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: const _TabHeader(),
            ),
            const SizedBox(height: 16),
            // Search bar
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
                  ),
                  child: TextField(
                    onChanged: prov.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: AppStrings.searchHint,
                      hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textTertiary),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Filter chips
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  _FilterChip(label: '${AppStrings.pending} (${prov.pendingCount})',
                      isActive: prov.activeFilter == 'Pendientes', onTap: () => prov.setFilter('Pendientes')),
                  const SizedBox(width: 8),
                  _FilterChip(label: AppStrings.approved,
                      isActive: prov.activeFilter == 'Aprobadas', onTap: () => prov.setFilter('Aprobadas')),
                  const SizedBox(width: 8),
                  _FilterChip(label: AppStrings.rejected,
                      isActive: prov.activeFilter == 'Rechazadas', onTap: () => prov.setFilter('Rechazadas')),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            // Requests list
            Expanded(
              child: prov.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                  : prov.filteredRequests.isEmpty
                      ? Center(child: Text('No hay solicitudes', style: GoogleFonts.inter(color: AppColors.textTertiary)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: prov.filteredRequests.length,
                          itemBuilder: (_, i) {
                            final req = prov.filteredRequests[i];
                            return FadeInUp(
                              duration: const Duration(milliseconds: 400),
                              delay: Duration(milliseconds: i * 80),
                              child: _RequestCard(request: req, provider: prov),
                            );
                          },
                        ),
            ),
          ]),
        );
      },
    );
  }
}

class _TabHeader extends StatelessWidget {
  const _TabHeader();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(children: [
          Expanded(child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(child: Text(AppStrings.notifications,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary))),
          )),
          Expanded(child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 8)],
            ),
            child: Center(child: Text(AppStrings.requests,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
          )),
        ]),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isActive, required this.onTap});
  final String label; final bool isActive; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.provider});
  final ReservationEntity request;
  final RequestsProvider provider;

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == ReservationStatus.pending;
    return Dismissible(
      key: Key(request.id),
      direction: isPending ? DismissDirection.horizontal : DismissDirection.none,
      background: _SwipeBg(color: AppColors.success, icon: Icons.check, alignment: Alignment.centerLeft),
      secondaryBackground: _SwipeBg(color: AppColors.error, icon: Icons.close, alignment: Alignment.centerRight),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          provider.approveRequest(request.id);
        } else {
          provider.rejectRequest(request.id);
        }
        return false;
      },
      child: NeonCard(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            CircleAvatar(
              radius: 22, backgroundColor: AppColors.surfaceLight,
              child: Icon(Icons.person_outline, color: AppColors.textSecondary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(request.userName, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
              Text(request.department ?? '', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: request.priority == RequestPriority.high
                    ? AppColors.accentOrange.withValues(alpha: 0.12)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: request.priority == RequestPriority.high
                    ? AppColors.accentOrange.withValues(alpha: 0.3) : AppColors.border.withValues(alpha: 0.3)),
              ),
              child: Text(
                request.priority == RequestPriority.high ? AppStrings.highPriority : AppStrings.normalPriority,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                    color: request.priority == RequestPriority.high ? AppColors.accentOrange : AppColors.textSecondary),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          // Details
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(AppStrings.equipment.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.8)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.videocam_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(child: Text(request.videobeamName, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                  ]),
                ])),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('UBICACIÓN', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.8)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.primaryBlue),
                    const SizedBox(width: 4),
                    Expanded(child: Text(request.location, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                  ]),
                ])),
              ]),
              const SizedBox(height: 10),
              Text('FECHA Y HORA', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${DateFormat('EEE dd MMM').format(request.date)} • ${request.startTime} - ${request.endTime}',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
              ]),
            ]),
          ),
          // Action buttons (only for pending)
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => provider.approveRequest(request.id),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Center(child: Text(AppStrings.approve,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.success))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => provider.rejectRequest(request.id),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
                    ),
                    child: Center(child: Text(AppStrings.reject,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                  ),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }
}

class _SwipeBg extends StatelessWidget {
  const _SwipeBg({required this.color, required this.icon, required this.alignment});
  final Color color; final IconData icon; final Alignment alignment;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 12)],
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
