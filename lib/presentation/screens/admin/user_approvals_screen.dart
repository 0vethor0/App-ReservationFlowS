/// Admin screen for managing user approvals.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/users_management/domain/entities/pending_user_entity.dart';
import '../../../features/users_management/presentation/providers/user_management_provider.dart';
import '../../../features/users_management/presentation/widgets/user_approval_card.dart';
import '../../components/global_back_button.dart';

class UserApprovalsScreen extends StatelessWidget {
  const UserApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Solicitudes Pendientes'),
        leading: const GlobalBackButton(),
        centerTitle: true,
      ),
      body: Consumer<UserManagementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.pendingUsers.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            );
          }

          if (provider.pendingUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: AppColors.success.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay solicitudes pendientes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Registros y promociones a admin están al día',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadPendingUsers(),
            color: AppColors.primaryBlue,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.pendingUsers.length,
              itemBuilder: (context, index) {
                final user = provider.pendingUsers[index];
                return UserApprovalCard(
                  user: user,
                  onApprove: () => _onApprove(context, provider, user),
                  onReject: () => _onReject(context, provider, user),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _onApprove(
    BuildContext context,
    UserManagementProvider provider,
    PendingUserEntity user,
  ) {
    if (user.kind == PendingApprovalKind.adminPromotion) {
      provider.approveAdminPromotion(user.id, context);
    } else {
      provider.approveUser(user.id, context);
    }
  }

  void _onReject(
    BuildContext context,
    UserManagementProvider provider,
    PendingUserEntity user,
  ) {
    if (user.kind == PendingApprovalKind.adminPromotion) {
      provider.rejectAdminPromotion(user.id, context);
    } else {
      provider.rejectUser(user.id, context);
    }
  }
}
