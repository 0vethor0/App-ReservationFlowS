/// Bottom filter bar for calendar: product + reservation status.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../features/view_reservation_calendar/domain/entities/calendar_product_entity.dart';
import '../../features/view_reservation_calendar/domain/entities/calendar_status_filter.dart';

class CalendarFilterBar extends StatelessWidget {
  const CalendarFilterBar({
    super.key,
    required this.products,
    required this.selectedProductId,
    required this.selectedStatus,
    required this.onProductSelected,
    required this.onStatusSelected,
  });

  final List<CalendarProductEntity> products;
  final String? selectedProductId;
  final CalendarStatusFilter selectedStatus;
  final ValueChanged<String?> onProductSelected;
  final ValueChanged<CalendarStatusFilter> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.35)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.calendarFilterProduct,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: AppStrings.calendarFilterAllProducts,
                      selected: selectedProductId == null,
                      onTap: () => onProductSelected(null),
                    ),
                    ...products.map(
                      (p) => _FilterChip(
                        label: p.name,
                        selected: selectedProductId == p.id,
                        onTap: () => onProductSelected(p.id),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.calendarFilterStatus,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: CalendarStatusFilter.values.map((status) {
                    return _FilterChip(
                      label: status.label,
                      selected: selectedStatus == status,
                      accentColor: _statusColor(status),
                      onTap: () => onStatusSelected(status),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(CalendarStatusFilter status) {
    switch (status) {
      case CalendarStatusFilter.approved:
        return AppColors.primaryBlue;
      case CalendarStatusFilter.inProgress:
        return AppColors.warning;
      case CalendarStatusFilter.completed:
        return AppColors.success;
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.accentColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primaryBlue;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.15)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? color
                    : AppColors.border.withValues(alpha: 0.5),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? color : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
