import 'package:flutter/material.dart';

/// Swiss / International Typographic Style palette.
///
/// Prinsip: hanya hitam, putih, off-white/abu-abu netral, dan satu aksen
/// (Swiss red). Tidak ada gradien, shadow, atau warna kedua. Batas tipis
/// (hairline 1px) menggantikan elevasi untuk membangun hierarki.
class AppColors {
  // ── Brand Aksen ──────────────────────────────────────────
  /// Merah Swiss — satu-satunya warna non-netral di sistem.
  static const Color accent = Color(0xFFE10600);

  // ── Light Mode ───────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface    = Color(0xFFFAFAFA);
  static const Color surfaceAlt = Color(0xFFF2F2F2);

  static const Color textPrimary   = Color(0xFF0A0A0A);
  static const Color textSecondary = Color(0xFF555555);
  static const Color textMuted     = Color(0xFF8A8A8A);
  static const Color textHint      = Color(0xFFB5B5B5);
  static const Color textInverse   = Color(0xFFFFFFFF);

  static const Color border      = Color(0xFF0A0A0A);
  static const Color borderMuted = Color(0xFFE0E0E0);
  static const Color divider    = Color(0xFFE0E0E0);

  static const Color error       = Color(0xFFE10600);
  static const Color success     = Color(0xFF0A0A0A);

  // ── Dark Mode ────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface    = Color(0xFF111111);
  static const Color darkSurfaceAlt = Color(0xFF1A1A1A);

  static const Color darkTextPrimary   = Color(0xFFFAFAFA);
  static const Color darkTextSecondary = Color(0xFFB5B5B5);
  static const Color darkTextMuted     = Color(0xFF8A8A8A);
  static const Color darkTextHint      = Color(0xFF555555);
  static const Color darkTextInverse   = Color(0xFF0A0A0A);

  static const Color darkBorder      = Color(0xFFFAFAFA);
  static const Color darkBorderMuted = Color(0xFF2A2A2A);
  static const Color darkDivider     = Color(0xFF2A2A2A);

  static const Color darkError   = Color(0xFFE10600);
  static const Color darkSuccess = Color(0xFFFAFAFA);
}