/// Constantes de colores para el sistema de diseño "Neon White".
///
/// Define la paleta completa de la app BeamReserve con
/// acentos azules, gradientes neon y fondo blanco puro.
import 'package:flutter/material.dart';

abstract final class AppColors {
  // ─── Background ───
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF7F9FC);
  static const Color surfaceCard = Color(0xFFF0F4FA);

  // ─── Primary Blues ───
  static const Color primaryBlue = Color(0xFF0066FF);
  static const Color primaryBlueDark = Color(0xFF2B4B9B);
  static const Color deepBlue = Color(0xFF28347D);
  static const Color lightBlue = Color(0xFFE8F0FE);
  static const Color softBlue = Color(0xFFD6E4FF);

  // ─── Accent Colors ───
  static const Color accentYellow = Color(0xFFF9BE13);
  static const Color accentOrange = Color(0xFFF4971F);

  // ─── Status Colors ───
  static const Color success = Color(0xFF34C759);
  static const Color successLight = Color(0xFFE8F9ED);
  static const Color error = Color(0xFFFF3B30);
  static const Color errorLight = Color(0xFFFEE8E7);
  static const Color warning = Color(0xFFFFCC00);
  static const Color warningLight = Color(0xFFFFF8E0);

  // ─── Neutral ───
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);
  static const Color disabled = Color(0xFFBDBDBD);

  // ─── Neon Glow Colors (used in BoxShadow) ───
  static const Color neonBlueGlow = Color(0xFF0066FF);
  static const Color neonGreenGlow = Color(0xFF34C759);
  static const Color neonRedGlow = Color(0xFFFF3B30);

  // ─── Gradients ───
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryBlue, Color(0xFF3D8BFF)],
  );

  static const LinearGradient deepGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepBlue, primaryBlue],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7F9FC), Color(0xFFEDF2FF)],
  );

  static const LinearGradient neonProgressGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF3D8BFF), primaryBlue],
  );
}
