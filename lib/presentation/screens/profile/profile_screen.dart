/// Profile Settings Screen — muestra datos del usuario, opción para solicitar
/// ser admin, políticas de uso y datos del desarrollador.
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/neon_card.dart';
import '../../../core/widgets/neon_button.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _ProfileAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Profile header
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: _ProfileHeader(
                  avatarUrl: user?.avatarUrl,
                  fullName: user?.fullName ?? 'Usuario',
                  email: user?.email ?? '',
                  role: user?.role,
                ),
              ),
              const SizedBox(height: 24),
              // Personal info card
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: _PersonalInfoCard(user: user),
              ),
              const SizedBox(height: 16),
              // Request admin button
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: _RequestAdminCard(role: user?.role),
              ),
              const SizedBox(height: 16),
              // Usage policies
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 300),
                child: const _UsagePoliciesCard(),
              ),
              const SizedBox(height: 32),
              // Developer footer
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 400),
                child: const _DeveloperFooter(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder<void>(
                pageBuilder: (_, _, _) => const DashboardScreen(),
                transitionsBuilder: (_, a, _, child) =>
                    FadeTransition(opacity: a, child: child),
                transitionDuration: const Duration(milliseconds: 350),
              ),
              (route) => false,
            );
          }
        },
      ),
      title: Text(
        AppStrings.profileSettings,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      ),
      centerTitle: false,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.avatarUrl, required this.fullName, required this.email, required this.role});
  final String? avatarUrl;
  final String fullName;
  final String email;
  final dynamic role;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(45),
              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3), width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(42),
              child: avatarUrl != null
                  ? Image.network(avatarUrl!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _AvatarFallback(initial: fullName))
                  : _AvatarFallback(initial: fullName),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            fullName,
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            email,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: role.toString() == 'UserRole.admin' ? AppColors.successLight : AppColors.lightBlue,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: role.toString() == 'UserRole.admin' ? AppColors.success.withValues(alpha: 0.3) : AppColors.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              role.toString() == 'UserRole.admin' ? 'Administrador' : 'Usuario',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: role.toString() == 'UserRole.admin' ? AppColors.success : AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initial});
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial.isNotEmpty ? initial[0].toUpperCase() : 'U',
        style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
      ),
    );
  }
}

class _PersonalInfoCard extends StatelessWidget {
  const _PersonalInfoCard({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final fullName = user?.fullName ?? '';
    final nameParts = fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return NeonCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.person_outline, color: AppColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.personalInfo,
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InfoRow(label: AppStrings.firstName, value: firstName, icon: Icons.badge_outlined),
          const SizedBox(height: 12),
          _InfoRow(label: AppStrings.lastName, value: lastName, icon: Icons.badge_outlined),
          const SizedBox(height: 12),
          _InfoRow(label: AppStrings.email, value: user?.email ?? '', icon: Icons.email_outlined),
          const SizedBox(height: 12),
          _InfoRow(label: AppStrings.phone, value: user?.phone ?? 'No especificado', icon: Icons.phone_outlined),
          const SizedBox(height: 12),
          _InfoRow(label: AppStrings.department, value: user?.department ?? 'No especificado', icon: Icons.business_outlined),
          const SizedBox(height: 20),
          NeonButton(
            text: AppStrings.saveChanges,
            height: 48,
            borderRadius: 16,
            icon: Icons.check,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.changesSaved),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Divider(color: AppColors.divider.withValues(alpha: 0.5)),
      ],
    );
  }
}

class _RequestAdminCard extends StatelessWidget {
  const _RequestAdminCard({required this.role});
  final dynamic role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role.toString() == 'UserRole.admin';

    return NeonCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: isAdmin ? AppColors.successLight : AppColors.softBlue, borderRadius: BorderRadius.circular(10)),
                child: Icon(
                  isAdmin ? Icons.verified : Icons.admin_panel_settings_outlined,
                  color: isAdmin ? AppColors.success : AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isAdmin ? AppStrings.alreadyAdmin : AppStrings.requestAdmin,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.requestAdminDesc,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          NeonButton(
            text: isAdmin ? AppStrings.alreadyAdmin : AppStrings.requestAdmin,
            height: 44,
            borderRadius: 14,
            icon: isAdmin ? Icons.check_circle : Icons.send_outlined,
            enabled: !isAdmin,
            gradient: isAdmin
                ? const LinearGradient(colors: [AppColors.success, Color(0xFF2ECC71)])
                : AppColors.primaryGradient,
            onPressed: isAdmin
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppStrings.adminRequestSent),
                        backgroundColor: AppColors.primaryBlue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}

class _UsagePoliciesCard extends StatelessWidget {
  const _UsagePoliciesCard();

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.policy_outlined, color: AppColors.accentOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.usagePolicies,
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.policiesContent,
            style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _DeveloperFooter extends StatelessWidget {
  const _DeveloperFooter();

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      padding: const EdgeInsets.all(20),
      glowOpacity: 0.06,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.code, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.developedBy,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.developer,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final url = Uri.parse('https://github.com/0vethor0');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.open_in_new, size: 16, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.githubProfile,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.divider.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          Text(
            '© 2026 BeamFlow. Todos los derechos reservados.',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
