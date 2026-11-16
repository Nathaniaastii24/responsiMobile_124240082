import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Kartu kaca: blur isi di belakangnya + gradasi ungu memudar + border putih.
/// Agar efeknya terlihat, letakkan di atas GradientBackground.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;

  /// Seberapa buram latar di belakang kartu. 8-16 sudah cukup.
  final double blur;

  /// Seberapa pekat warna kartu (0.0 - 1.0). Makin kecil makin bening.
  final double opacity;

  /// Daftar warna cahaya: AppColors.cardGlow / cardGlowPink / cardGlowBlue
  final List<Color> glow;

  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = 24,
    this.blur = 14,
    this.opacity = 0.62,
    this.glow = const [
      Color(0xFFE5D5F8),
      Color(0xFFF3EAFC),
      Color(0xFFFFFFFF),
    ],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    return Container(
      margin: margin,
      // Bayangan harus di luar ClipRRect, kalau tidak ikut terpotong.
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: glow
                    .map((c) => c.withValues(alpha: opacity))
                    .toList(),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 1.2,
              ),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}