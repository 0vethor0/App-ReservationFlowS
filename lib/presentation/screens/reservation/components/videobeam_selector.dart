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
    this.isLoading = false,
    this.onRefresh,
  });

  final List<VideobeamEntity> videobeams;
  final VideobeamEntity? selected;
  final ValueChanged<VideobeamEntity> onSelect;
  final bool isLoading;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.selectVideobeam,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onRefresh != null)
              IconButton(
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryBlue,
                        ),
                      )
                    : const Icon(
                        Icons.refresh,
                        size: 20,
                        color: AppColors.primaryBlue,
                      ),
                onPressed: isLoading ? null : onRefresh,
                tooltip: 'Recargar equipos',
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (videobeams.isEmpty && isLoading)
          Container(
            // CAMBIO: Usamos minHeight en lugar de height fijo
            constraints: const BoxConstraints(minHeight: 110),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Importante: que la columna solo ocupe lo necesario
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(height: 8),
                Text(
                  'Cargando equipos...',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else if (videobeams.isEmpty)
          Container(
            // CAMBIO: Permitimos que crezca si el botón "Recargar" aparece
            constraints: const BoxConstraints(minHeight: 110),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Importante
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.videocam_off_outlined,
                  color: AppColors.disabled,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'No hay equipos disponibles',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.disabled,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (onRefresh != null) ...[
                  const SizedBox(height: 4), // Reducido un poco el espacio
                  TextButton(
                    onPressed: onRefresh,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, // Reduce el padding interno del botón
                      minimumSize: const Size(0, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Recargar',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
        else
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
                          ? AppColors.primaryBlue.withValues(alpha: 0.12)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.border.withValues(alpha: 0.2),
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(alpha: 0.25),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.videocam_outlined,
                              color: isAvailable ? AppColors.primaryBlue : AppColors.disabled,
                              size: 22,
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryBlue,
                                size: 18,
                              ),
                          ],
                        ),
                        Text(
                          v.name,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
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
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.success.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Disponible',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.success,
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