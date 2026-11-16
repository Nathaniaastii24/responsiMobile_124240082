import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Latar gradasi pink-lavender dengan lingkaran cahaya berwarna.
/// Lingkaran memakai RadialGradient (bukan blur filter) supaya ringan.
/// Warna-warna inilah yang nanti terlihat tembus pandang di balik GlassCard.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.backgroundGradient,
        ),
      ),
      child: Stack(
        children: [
          _glow(top: -90, left: -80, size: 320, color: AppColors.pink),
          _glow(top: 220, right: -120, size: 340, color: AppColors.purple),
          _glow(bottom: -100, left: -60, size: 320, color: AppColors.blue),
          child,
        ],
      ),
    );
  }

  Widget _glow({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.55),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}