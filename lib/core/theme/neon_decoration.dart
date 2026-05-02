/// Mixin y widgets de decoración Neon para el sistema "Neon White".
///
/// Provee efectos de glow (BoxShadow) reutilizables con
/// blur: 18–25, spread: 2–4, opacidad 25–40%.
library;
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Mixin que provee decoraciones neon reutilizables.
mixin NeonDecoration {
  /// Sombra neon azul estándar.
  static List<BoxShadow> neonGlow({
    Color color = AppColors.neonBlueGlow,
    double blurRadius = 20,
    double spreadRadius = 3,
    double opacity = 0.30,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }

  /// Sombra neon sutil para cards.
  static List<BoxShadow> neonCardShadow({
    Color color = AppColors.neonBlueGlow,
    double opacity = 0.12,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: 18,
        spreadRadius: 2,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Sombra neon intensa para botones presionados.
  static List<BoxShadow> neonButtonGlow({
    Color color = AppColors.neonBlueGlow,
    double opacity = 0.40,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: 25,
        spreadRadius: 4,
      ),
    ];
  }

  /// Sombra neon para campos de texto con foco.
  static List<BoxShadow> neonFocusGlow({
    Color color = AppColors.neonBlueGlow,
    double opacity = 0.25,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: 18,
        spreadRadius: 2,
      ),
    ];
  }
}

/// Widget contenedor con efecto neon configurable.
class NeonContainer extends StatelessWidget {
  const NeonContainer({
    super.key,
    required this.child,
    this.glowColor = AppColors.neonBlueGlow,
    this.glowOpacity = 0.25,
    this.blurRadius = 20,
    this.spreadRadius = 3,
    this.borderRadius = 20,
    this.padding,
    this.gradient,
    this.backgroundColor,
    this.border,
    this.width,
    this.height,
  });

  final Widget child;
  final Color glowColor;
  final double glowOpacity;
  final double blurRadius;
  final double spreadRadius;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Border? border;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: gradient == null
            ? (backgroundColor ?? AppColors.background)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: glowOpacity),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
