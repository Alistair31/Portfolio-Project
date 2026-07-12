import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bouton circulaire blanc avec une icône (cloche, retour…).
/// [bordered] ajoute un contour fin, [elevated] une ombre portée douce.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final bool bordered;
  final bool elevated;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 44,
    this.iconSize = 22,
    this.bordered = false,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: bordered ? Border.all(color: AppColors.hairline) : null,
          boxShadow: elevated
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, size: iconSize, color: AppColors.racingGreen),
      ),
    );
  }
}
