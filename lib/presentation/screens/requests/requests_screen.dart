/// Gestión de Solicitudes — lista con Dismissible, filtros y búsqueda.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';

import '../../providers/requests_provider.dart';

import 'components/request_card.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestsProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Solo el Search bar como header principal
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.2),
                      ),
                    ),
                    child: TextField(
                      onChanged: provider.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Buscar solicitudes...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Filter chips - Ajustados para que quepan todos
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 100),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _FilterChipItem(
                        label: '${AppStrings.pending} (${provider.pendingCount})',
                        isActive: provider.activeFilter == 'Pendientes',
                        onTap: () => provider.setFilter('Pendientes'),
                      ),
                      const SizedBox(width: 10),
                      _FilterChipItem(
                        label: AppStrings.approved,
                        isActive: provider.activeFilter == 'Aprobadas',
                        onTap: () => provider.setFilter('Aprobadas'),
                      ),
                      const SizedBox(width: 10),
                      _FilterChipItem(
                        label: AppStrings.rejected,
                        isActive: provider.activeFilter == 'Rechazadas',
                        onTap: () => provider.setFilter('Rechazadas'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Requests list
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      )
                    : provider.filteredRequests.isEmpty
                        ? Center(
                            child: Text(
                              'No hay solicitudes',
                              style: GoogleFonts.inter(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: provider.filteredRequests.length,
                            itemBuilder: (_, i) {
                              final req = provider.filteredRequests[i];
                              return FadeInUp(
                                duration: const Duration(milliseconds: 400),
                                delay: Duration(milliseconds: i * 80),
                                child: RequestCard(
                                  request: req,
                                  provider: provider,
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}