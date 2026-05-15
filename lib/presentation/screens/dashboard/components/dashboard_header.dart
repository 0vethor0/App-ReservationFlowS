/// Header del Dashboard con información del usuario y acciones.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import '../../../providers/auth_provider.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.user,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  final UserEntity? user;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.hello,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    user?.fullName ?? 'Usuario', //NOMBRE DEL USUARIO
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const _AdminAccessButton(),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  icon: Icons.settings_outlined,
                  onTap: onSettingsTap,
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  icon: Icons.logout,
                  onTap: onLogoutTap,
                  isLogout: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatefulWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.isLogout = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isLogout;

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isLogout ? AppColors.error : AppColors.primaryBlue;
    final bgColor = widget.isLogout
        ? AppColors.errorLight
        : AppColors.lightBlue;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnimation.value, child: child),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: iconColor.withValues(alpha: _isPressed ? 0.4 : 0.2),
            ),
          ),
          child: Icon(widget.icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}

/// Button to access admin user approvals panel (only visible for admins)
class _AdminAccessButton extends StatelessWidget {
  const _AdminAccessButton();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    // Only show for admin or superAdmin
    if (user == null ||
        (user.role != UserRole.admin && user.role != UserRole.superAdmin)) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => context.go('/admin/user-approvals'),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.accentYellow.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accentYellow.withValues(alpha: 0.3),
          ),
        ),
        child: const Icon(
          Icons.admin_panel_settings_outlined,
          color: AppColors.accentYellow,
          size: 22,
        ),
      ),
    );
  }
}
