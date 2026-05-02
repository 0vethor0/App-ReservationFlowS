/// Card con sombra neon y bordes redondeados.
library;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/neon_decoration.dart';

class NeonCard extends StatelessWidget {
  const NeonCard({
    super.key,
    required this.child,
    this.glowColor = AppColors.neonBlueGlow,
    this.glowOpacity = 0.10,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.gradient,
    this.backgroundColor,
    this.onTap,
    this.border,
  });

  final Widget child;
  final Color glowColor;
  final double glowOpacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: gradient == null
                  ? (backgroundColor ?? AppColors.background)
                  : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: AppColors.border.withValues(alpha: 0.15),
                    width: 1,
                  ),
              boxShadow: [
                ...NeonDecoration.neonCardShadow(
                  color: glowColor,
                  opacity: glowOpacity,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
