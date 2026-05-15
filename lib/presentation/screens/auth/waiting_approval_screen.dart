/// Screen displayed when user is waiting for admin approval.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/domain/entities/user_entity.dart';

class WaitingApprovalScreen extends StatelessWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final status = authProvider.currentUserStatus;

                // If approved, navigate to dashboard
                if (status == UserStatus.approved) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go('/');
                  });
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(seconds: 1),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: status == UserStatus.rejected
                              ? AppColors.errorLight
                              : AppColors.lightBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          status == UserStatus.rejected
                              ? Icons.cancel_outlined
                              : Icons.hourglass_top,
                          size: 80,
                          color: status == UserStatus.rejected
                              ? AppColors.error
                              : AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    Text(
                      status == UserStatus.rejected
                          ? 'Cuenta Rechazada'
                          : 'Cuenta Pendiente de Aprobación',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: status == UserStatus.rejected
                            ? AppColors.error
                            : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      status == UserStatus.rejected
                          ? 'Tu cuenta ha sido rechazada. Por favor, contacta al administrador para más información.'
                          : 'Tu registro ha sido exitoso. Un administrador debe aprobar tu cuenta antes de que puedas acceder al sistema.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Loading indicator (only for pending status)
                    if (status == UserStatus.pending) ...[
                      const CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Esperando aprobación...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    // Contact support button
                    OutlinedButton.icon(
                      onPressed: () {
                        // Add contact support logic here
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Contactar Soporte'),
                            content: const Text(
                              'Por favor, contacta al Coordinador de la carrera de Ing de Sistemas, el Ing. Rafael Lopez, para obtener mas informacion.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Entendido'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.support_agent),
                      label: const Text('Contactar Soporte'),
                    ),
                    const SizedBox(height: 16),
                    // Sign out button
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cerrar Sesión'),
                            content: const Text(
                              '¿Estás seguro que deseas cerrar sesión?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  authProvider.signOut();
                                },
                                child: const Text('Cerrar Sesión'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar Sesión'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textTertiary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
