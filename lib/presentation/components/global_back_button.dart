/// Global reusable back button component.
///
/// Provides consistent navigation-back behavior across all screens.
/// Uses GoRouter for proper navigation handling.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class GlobalBackButton extends StatelessWidget {
  const GlobalBackButton({
    super.key,
    this.iconSize = 20,
    this.color,
  });

  final double iconSize;
  final Color? color;

  void _handleBack(BuildContext context) {
    final router = GoRouter.of(context);
    
    // If we can pop from the router stack, do it
    if (router.canPop()) {
      context.pop();
    } else {
      // Otherwise, go to dashboard (root route)
      router.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new,
        size: iconSize,
        color: color ?? AppColors.textPrimary,
      ),
      onPressed: () => _handleBack(context),
    );
  }
}
