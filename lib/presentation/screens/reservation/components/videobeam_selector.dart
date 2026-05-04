/// Componente de selección de videobeam.
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/entities.dart';

class VideobeamSelector extends StatelessWidget {
  const VideobeamSelector({
    super.key,
    required this.videobeams,
    required this.selected,
    required this.onSelect,
  });

  final List<VideobeamEntity> videobeams;
  final VideobeamEntity? selected;
  final ValueChanged<VideobeamEntity> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.selectVideobeam,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
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
                    color: isSelected
                        ? AppColors.primaryBlue.withValues(alpha: 0.06)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.border.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(alpha: 0.15),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.videocam_outlined,
                        color: isAvailable ? AppColors.primaryBlue : AppColors.disabled,
                        size: 22,
                      ),
                      Text(
                        v.name,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isAvailable ? AppColors.textPrimary : AppColors.disabled,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: v.status == VideobeamStatus.available
                                  ? AppColors.success
                                  : v.status == VideobeamStatus.inUse
                                      ? AppColors.accentOrange
                                      : AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            v.status == VideobeamStatus.available
                                ? 'Disponible'
                                : v.status == VideobeamStatus.inUse
                                    ? 'En Uso'
                                    : 'Mant.',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}