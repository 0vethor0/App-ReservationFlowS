/// Botones de acción para administradores.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_button.dart';
import '../../../providers/requests_provider.dart';

class AdminActionButtons extends StatelessWidget {
  const AdminActionButtons({
    super.key,
    required this.onProductsTap,
    required this.onRequestsTap,
  });

  final VoidCallback onProductsTap;
  final VoidCallback onRequestsTap;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 300),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: NeonButton(
              text: 'Equipos',
              height: 48,
              borderRadius: 24,
              icon: Icons.inventory_2_outlined,
              onPressed: onProductsTap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Consumer<RequestsProvider>(
              builder: (_, rp, _) => InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onRequestsTap,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    ),
                    color: AppColors.lightBlue.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.mail_outline,
                        size: 18,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Peticiones',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${rp.pendingCount}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
