/// Pantalla de Reservación de Videobeam — selector, calendario, horarios.
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/neon_card.dart';
import '../../../core/widgets/neon_button.dart';
import '../../providers/reservation_provider.dart';
import '../../../domain/entities/entities.dart';

class ReservationScreen extends StatelessWidget {
  const ReservationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReservationProvider>(
      builder: (context, prov, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 20),
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Text(AppStrings.reserve,
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 20),

              // Videobeam selector
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: _VideobeamSelector(videobeams: prov.videobeams, selected: prov.selectedVideobeam,
                    onSelect: (v) => prov.selectVideobeam(v)),
              ),
              const SizedBox(height: 24),

              // Calendar
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: _CalendarSection(selectedDate: prov.selectedDate,
                    onDateSelected: (d) => prov.selectDate(d)),
              ),
              const SizedBox(height: 24),

              // Time slots
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 300),
                child: _TimeSlotGrid(
                  slots: prov.generateTimeSlots(),
                  selectedSlots: prov.selectedTimeSlots,
                  onToggle: (s) => prov.toggleTimeSlot(s),
                ),
              ),
              const SizedBox(height: 24),

              // Summary + confirm
              if (prov.selectedVideobeam != null && prov.selectedTimeSlots.isNotEmpty)
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  child: _ReservationSummary(prov: prov),
                ),
              const SizedBox(height: 100),
            ]),
          ),
        );
      },
    );
  }
}

class _VideobeamSelector extends StatelessWidget {
  const _VideobeamSelector({required this.videobeams, required this.selected, required this.onSelect});
  final List<VideobeamEntity> videobeams;
  final VideobeamEntity? selected;
  final ValueChanged<VideobeamEntity> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppStrings.selectVideobeam, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: videobeams.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final v = videobeams[i];
            final isSelected = selected?.id == v.id;
            final isAvailable = v.status == VideobeamStatus.available;
            return GestureDetector(
              onTap: isAvailable ? () => onSelect(v) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 140,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.06) : AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBlue : AppColors.border.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.15), blurRadius: 12, spreadRadius: 1)] : [],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Icon(Icons.videocam_outlined, color: isAvailable ? AppColors.primaryBlue : AppColors.disabled, size: 22),
                  Text(v.name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                      color: isAvailable ? AppColors.textPrimary : AppColors.disabled), maxLines: 2, overflow: TextOverflow.ellipsis),
                  Row(children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(
                      color: v.status == VideobeamStatus.available ? AppColors.success
                          : v.status == VideobeamStatus.inUse ? AppColors.accentOrange : AppColors.error,
                      shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(v.status == VideobeamStatus.available ? 'Disponible'
                        : v.status == VideobeamStatus.inUse ? 'En Uso' : 'Mant.',
                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary)),
                  ]),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class _CalendarSection extends StatelessWidget {
  const _CalendarSection({required this.selectedDate, required this.onDateSelected});
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(14, (i) => now.add(Duration(days: i)));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppStrings.selectDate, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: days.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final d = days[i];
            final isSelected = d.year == selectedDate.year && d.month == selectedDate.month && d.day == selectedDate.day;
            return GestureDetector(
              onTap: () => onDateSelected(d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 54, height: 74,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.border.withValues(alpha: 0.3)),
                  boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.30), blurRadius: 16, spreadRadius: 2)] : [],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(DateFormat('EEE', 'es').format(d).substring(0, 3).toUpperCase(),
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.textTertiary)),
                  const SizedBox(height: 4),
                  Text('${d.day}', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary)),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class _TimeSlotGrid extends StatelessWidget {
  const _TimeSlotGrid({required this.slots, required this.selectedSlots, required this.onToggle});
  final List<String> slots;
  final Set<String> selectedSlots;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    // Show a subset for UI (8am - 6pm key slots)
    final displaySlots = slots.where((s) {
      final h = int.parse(s.split(':')[0]);
      final m = int.parse(s.split(':')[1]);
      return h >= 8 && h <= 18 && m == 0;
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppStrings.selectTime, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Wrap(spacing: 10, runSpacing: 10,
        children: displaySlots.map((s) {
          final isSelected = selectedSlots.contains(s);
          return GestureDetector(
            onTap: () => onToggle(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.30), blurRadius: 12, spreadRadius: 1)]
                    : [],
              ),
              child: Text(s, style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary)),
            ),
          );
        }).toList(),
      ),
    ]);
  }
}

class _ReservationSummary extends StatelessWidget {
  const _ReservationSummary({required this.prov});
  final ReservationProvider prov;

  @override
  Widget build(BuildContext context) {
    final sortedSlots = prov.selectedTimeSlots.toList()..sort();
    return NeonCard(
      glowOpacity: 0.15,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppStrings.reservationSummary, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _SummaryRow(icon: Icons.videocam_outlined, label: AppStrings.equipment, value: prov.selectedVideobeam?.name ?? ''),
        const SizedBox(height: 8),
        _SummaryRow(icon: Icons.location_on_outlined, label: AppStrings.location, value: prov.selectedVideobeam?.location ?? ''),
        const SizedBox(height: 8),
        _SummaryRow(icon: Icons.calendar_today, label: AppStrings.dateAndTime,
            value: '${DateFormat('dd MMM yyyy').format(prov.selectedDate)} • ${sortedSlots.first} - ${sortedSlots.last}'),
        const SizedBox(height: 16),
        NeonButton(
          text: AppStrings.confirmReservation,
          onPressed: () async {
            final success = await prov.confirmReservation();
            if (!context.mounted) return;
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Reservación confirmada'), backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              );
              prov.reset();
            }
          },
          isLoading: prov.isLoading,
        ),
      ]),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.label, required this.value});
  final IconData icon; final String label; final String value;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: AppColors.primaryBlue),
      const SizedBox(width: 10),
      Text('$label: ', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
      Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
    ]);
  }
}
