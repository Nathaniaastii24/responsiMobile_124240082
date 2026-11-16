import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class Results extends StatelessWidget {
  final double size;
  final Color ringColor;

  const Results({
    super.key,
    this.size = 96,
    this.ringColor = AppColors.purpleSoft,
  });

  static const String url =
      'https://api.spaceflightnewsapi.net/v4/articles/40854/https://assets.science.nasa.gov/dynamicimage/assets/science/missions/webb/science/2026/10/weic2620a.jpg';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.06),
      decoration: BoxDecoration(shape: BoxShape.circle, color: ringColor),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.purple,
                  ),
                ),
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.blue,
            child: Icon(
              Icons.science_rounded,
              size: size * 0.5,
              color: AppColors.purple,
            ),
          ),
        ),
      ),
    );
  }
}

/// Latar lavender dengan blob dan coretan putih seperti pada referensi.
class HabitzBackground extends StatelessWidget {
  final Widget child;

  const HabitzBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Stack(
        children: [
          Positioned(
            left: -80,
            bottom: -60,
            child: _blob(240, AppColors.backgroundDeep),
          ),
          Positioned(
            right: -90,
            top: 120,
            child: _blob(260, AppColors.backgroundDeep.withOpacity(0.5)),
          ),
          
          child,
        ],
      ),
    );
  }

  static Widget _blob(double s, Color c) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(
      color: c,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(s * 0.55),
        topRight: Radius.circular(s * 0.4),
        bottomLeft: Radius.circular(s * 0.45),
        bottomRight: Radius.circular(s * 0.6),
      ),
    ),
  );

  static Widget _dash(double angle) => Transform.rotate(
    angle: angle,
    child: Container(
      width: 34,
      height: 5,
      decoration: BoxDecoration(
        color: AppColors.purpleSoft,
        borderRadius: BorderRadius.circular(3),
      ),
    ),
  );
}

/// Tile pastel (seperti kartu "Mood" / "Mes habitudes").
class PastelTile extends StatelessWidget {
  final Color color;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  const PastelTile({
    super.key,
    required this.color,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
